require_relative 'relation'
require_relative 'usage'

# TODO: STOP USING @@uses[self.to_s] to_s sucks in this case

class FragmentLoader
  @@relations = {}
  @@groups = {}
  @@uses = {}
  @@tmp = []

  def self.uses(fragment)
    @@uses[fragment] ||= []
    @@uses[fragment]
  end

  def self.tmp(index)
    @@tmp[index]
  end

  def self.tmp_add(v)
    @@tmp << v
  end

  def self.tmp_length
    @@tmp.length
  end

  def self.all_uses(fragment)
    uses = uses(fragment)

    all_use = uses

    #TODO: Fix cross dependencies?
    # Fix this implementation.... It is really bad
    uses.each do |use|
      all_use += all_uses(use.to_s)
      all_use.uniq!
    end

    all_use
  end
=begin
  def self.add_configuration(group, class_name, methods)
    @@groups[group] ||= []
    @@groups[group] << class_name


    #@@groups[group] ||= {}

    #@@groups[group][class_name] ||= []
    #@@groups[group][class_name] += methods
  end
=end

  #TODO: WE could probably improve with merging stuff. Think more about it
  def self.add_relation(relation)
    parent = relation.parent.to_s
    @@relations[parent] ||= []

    @@relations[parent] << relation
  end

  def self.add_configuration(group, class_name)
    @@groups[group] ||= []
    @@groups[group] << class_name
  end

  def self.set_configuration(group, configuration)
    # By default we append the configuration name to the class name.
    # TODO: Add ability to specify what file should be loaded
    # Also (mb) TODO: When new modules are loaded, we MIGHT have to save this information and reapply to new fragments
    # also verify that no methods go from implemented to implemented

    if @@groups[group].nil?
      log "Group '#{group}' is not set"
    end

    @@groups[group].each do |class_name|
      module_name = "#{class_name.split("::").last}#{configuration}"
      Kernel.const_get(class_name).uses(module_name)
    end
  end

  def self.load_fragments
    Dir['fragments/*.rb'].each do |file|
      load_fragment_file(file)
    end
  end

  def self.load_fragment(module_name)
    file_name = "fragments/#{module_name.to_s.scan(/[A-Z]{1,}[a-z]*/).join('_').downcase}.rb"
    load_fragment_file(file_name)
  end

  def self.load_fragment_file(file)
    log "Requiring fragment file '#{file}'"
    module_name = File.basename(file).split(".").first.split("_").map(&:capitalize).join

    if Kernel.const_defined?(module_name)
      log "#{module_name} already defined"
    else
      Kernel.const_set(module_name, Module.new do
        @@state = {}

        def self.load(state)
          @@state = state
        end

        def self.unload
          @@state = {}
        end

        def self.set_state!(state)
          @@state ||= {} # TODO: Is this nasty? It happens on configuration change. WE should rather SAVE the state and put it in the new configuration
          @@state.merge!(state)
        end

        def self.state(key, msg=nil)
          msg ||= "State #{key} not set"
          @@state ||= {} # TODO: Is this nasty? It happens on configuration change. WE should rather SAVE the state and put it in the new configuration
          raise msg unless @@state.key?(key)

          @@state[key]
        end

        # This entire thing is really bad.. Method_missing and respond_to? are copy paste

        def self.method_missing(method, *args)
          return public_send(method, *args) if methods(false).include?(method)

          FragmentLoader::uses(self.to_s).each do |use|
            return use.public_send(method, *args) if use.respond_to?(method, args)
          end

          if nesting.length > 1
            return nesting[1].send(:method_missing, *([method] + args))
          end

          super
        end

        def self.const_missing(const)
          FragmentLoader::all_uses(self.to_s).each do |use|
            if use.to_s.split('::').last == const.to_s
              $self = self
              FragmentLoader.tmp_add($self)

              tmp = Kernel.const_get(const).dup
              FragmentLoader.tmp_add(tmp)

              # def self.to_s IS SO BAD?? TODO: FIX ME
              # Why does it exist? To fix multi stacking A::B::C
              # TODO: Fix this nesting method as well. Expected [A, B, C], actual: [B, C]
              tmp.module_eval(%{
              set_state!('foo' => 'bar')
              def self.to_s
                "Kernel::#{const}"
              end

              def self.nesting
                [self, FragmentLoader.tmp(#{FragmentLoader.tmp_length-2})]
              end
                              })

              return tmp
            end
          end

          super
        end

        #Optimize this
        def self.respond_to?(method, *args)
          return true if methods(false).include?(method)

          FragmentLoader::uses(self.to_s).each do |use|
            return true if use.respond_to?(method, args)
          end

          super
        end

        def self.nesting
          Module.nesting
        end

        def self.uses(*modules)
          modules.each do |module_with|
            unless Kernel.const_defined?(module_with)
              FragmentLoader.load_fragment(module_with)
            end

            FragmentLoader::uses(self.to_s) << Kernel.const_get(module_with)




=begin
            m = Kernel.const_get(module_with)
            methods = m.methods(false)

            methods.each do |method|
              parameters = m.method(method).parameters

              parameter_names = parameters.map{|parameter| parameter.last}

              parameter_names.map! &:to_s

              self.class_eval %Q(
                    def self.#{method}(#{parameter_names.join(',')})
                              #{m}.#{method}(#{parameter_names.join(',')})
                  end
                  )
            end
=end
          end
        end

=begin
        def self.configuration(configuration_groups)
          configuration_groups.each do |group, methods|
            methods = [methods] unless methods.is_a?(Array)

            FragmentLoader.add_configuration(group, self.to_s, methods)
          end
        end
=end

        def self.configuration(group)
          FragmentLoader.add_configuration(group, self.to_s)
        end
      end)

      unless File.exists?(file)
        raise "Trying to load non-existing fragment '#{file}'"
      end

      require File.expand_path(file)
    end
  end
end
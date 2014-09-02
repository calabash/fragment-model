require_relative 'relation'
require_relative 'usage'

class FragmentLoader
  @@relations = {}
  @@groups = {}

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
          @@state.merge!(state)
        end

        def self.state(key)
          raise "State #{key} not set" unless @@state.key?(key)

          @@state[key]
        end

        def self.method_missing(method, *args)
          @@uses.each do |use|
            if use.respond_to?(method, args)
              return use.send(method, *args)
            end
          end

          super.method_missing(method, *args)
        end

        def self.uses(*modules)
          @@uses ||= []

          modules.each do |module_with|
            unless Kernel.const_defined?(module_with)
              FragmentLoader.load_fragment(module_with)
            end

            @@uses << Kernel.const_get(module_with)




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
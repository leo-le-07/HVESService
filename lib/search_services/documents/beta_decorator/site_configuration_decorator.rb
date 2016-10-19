module SearchServices
  module Documents
    module BetaDecorator
      class SiteConfigurationDecorator < SimpleDelegator

        def to_json_for_create
          { index: { _id: self[:config_key], data: fields } }
        end

        def to_json_for_delete
          { delete: { _id: self[:config_key] } }
        end

        private

        def fields
          {
            config_key: self[:config_key],
            config_value: self[:config_data]
          }
        end
        
      end
    end
  end
end

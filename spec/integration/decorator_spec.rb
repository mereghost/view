RSpec.describe 'decorator' do
  before do
    module Test
      class CustomPart < Dry::View::Part
        def to_s
          "Custom part wrapping #{_value}"
        end
      end
    end
  end

  describe 'default decorator' do
    it 'supports wrapping in custom part classes provided to exposure :as option' do
      vc = Class.new(Dry::View::Controller) do
        configure do |config|
          config.paths = SPEC_ROOT.join('fixtures/templates')
          config.layout = nil
          config.template = 'decorated_parts'
        end

        expose :custom, as: Test::CustomPart
        expose :ordinary
      end.new

      expect(vc.(custom: 'custom thing', ordinary: 'ordinary thing')).to eql(
        '<p>Custom part wrapping custom thing</p><p>ordinary thing</p>'
      )
    end
  end

  describe 'custom decorator and part classes' do
    it 'supports wrapping in custom parts based on exposure names' do
      decorator = Class.new(Dry::View::Decorator) do
        def part_class(name, options)
          name == :custom ? Test::CustomPart : super
        end
      end.new

      vc = Class.new(Dry::View::Controller) do
        configure do |config|
          config.decorator = decorator
          config.paths = SPEC_ROOT.join('fixtures/templates')
          config.layout = nil
          config.template = 'decorated_parts'
        end

        expose :custom, :ordinary
      end.new

      expect(vc.(custom: 'custom thing', ordinary: 'ordinary thing')).to eql(
        '<p>Custom part wrapping custom thing</p><p>ordinary thing</p>'
      )
    end


  end
end

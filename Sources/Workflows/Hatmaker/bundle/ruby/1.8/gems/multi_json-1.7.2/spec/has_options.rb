shared_examples_for 'has options' do |object|

  if object.respond_to?(:call)
    subject{ object.call }
  else
    subject{ object }
  end

  %w(dump_options load_options).each do |getter|

    let(:getter){ getter }
    let(:default_getter){ "default_#{getter}" }
    let(:setter){ "#{getter}=" }
    let(:defaults){ subject.send(default_getter) }
    let(:ivar){ "@#{getter}" }

    describe getter.tr('_', ' ') do
      before{ set nil }
      after{ set nil }

      def get(*args)
        subject.send(getter, *args)
      end

      def set(value)
        subject.send(setter, value)
      end

      it 'returns default options if not set' do
        expect(get).to eq(defaults)
      end

      it 'allows hashes' do
        set :foo => 'bar'
        expect(get).to eq(:foo => 'bar')
      end

      it 'allows objects that implement #to_hash' do
        value = Class.new do
          def to_hash
            {:foo=>'bar'}
          end
        end.new

        set value
        expect(get).to eq(:foo => 'bar')
      end

      it 'evaluates lambda returning options (with args)' do
        set lambda{ |a1, a2| { a1 => a2 }}
        expect(get('1', '2')).to eq('1' => '2')
      end

      it 'evaluates lambda returning options (with no args)' do
        set lambda{{:foo => 'bar'}}
        expect(get).to eq(:foo => 'bar')
      end

      it 'returns empty hash in all other cases' do
        set true
        expect(get).to eq(defaults)

        set false
        expect(get).to eq(defaults)

        set 10
        expect(get).to eq(defaults)

        set nil
        expect(get).to eq(defaults)
      end
    end
  end
end
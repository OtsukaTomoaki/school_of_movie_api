RSpec.shared_context 'create_user' do
  let!(:user_1) {
    FactoryBot.create(:user,
      name: 'Foo婆バズ_1',
      email: "user_1@gmail.com"
    )
  }
  let!(:user_2) {
    FactoryBot.create(:user,
      name: 'Foo婆バズ_2',
      email: "user_2@gmail.com"
    )
  }
  let!(:user_3) {
    FactoryBot.create(:user,
      name: 'Foo婆バズ_3',
      email: "user_3@gmail.com"
    )
  }
end
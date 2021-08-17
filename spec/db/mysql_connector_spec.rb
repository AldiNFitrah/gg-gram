require './db/mysql_connector.rb'


describe MySqlClient do

  describe 'is singleton' do
    context 'given 2 db client' do
      it 'returns the same instance' do
        db_client1 = MySqlClient.instance()
        db_client2 = MySqlClient.instance()

        expect(db_client1).to(eq(db_client2))
      end
    end
  end
end

Provider.seed(:id,
              {
                  id: 1,
                  name: 'erkatoy',
                  password: '12345',
                  sync_transaction_url: 'http://example.com/sync_transaction',
                  sync_user_url: 'http://example.com/sync_users',
                  click_params: { secret_key: 'SomeSecretKey' },
                  paynet_params: { user_name: 'erkatoy_name', password: 'erkatoy_psw' }
              },
              {
                  id: 2,
                  name: 'tom',
                  password: '12345',
                  sync_transaction_url: 'http://example.com/sync_transaction',
                  sync_user_url: 'http://example.com/sync_users',
                  click_params: { secret_key: 'SomeSecretKey' },
                  paynet_params: { user_name: 'TomUz2014', password: 'tom10v000317' }
              }
)

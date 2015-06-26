Provider.seed(:id,
              {
                  id: 1,
                  name: 'erkatoy',
                  password: '123456',
                  sync_transaction_url: '',
                  sync_user_url: '',
                  click_params: { secret_key: '5nfEV2u31c9X6reT$Q-RGKUm', service_id: 125 },
                  paynet_params: { user_name: '', password: '' }
              },
              {
                  id: 2,
                  name: 'tom',
                  password: '123456',
                  sync_transaction_url: '',
                  sync_user_url: '',
                  click_params: { secret_key: '' },
                  paynet_params: { user_name: 'TomUz2014', password: 'tom10v000317' }
              },
              {
                  id: 3,
                  name: 'itest',
                  password: '12345678',
                  sync_transaction_url: 'http://192.168.0.13/pays/add-payment',
                  sync_user_url: 'http://itest.uz/pays/users',
                  click_params: { secret_key: 'oG4VyyfJq2v#0FdIr@Ll2LAq' },
                  paynet_params: { user_name: 'itest', password: 'Kjwe1Djk52dwp_tw' },
                  weak_account_verification: true
              }
)

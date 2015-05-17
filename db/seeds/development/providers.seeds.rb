Provider.seed(:id,
  {
      id: 1,
      name: 'tom',
      password: '123',
      sync_transaction_url: 'http://example.com/sync_transaction',
      sync_user_url: 'http://example.com/sync_users',
      click_params: { secret_key: 'asewg2gr4hset' },
      paynet_params: { user_name: 'tomname', password: 'tompsw' }
  }
)

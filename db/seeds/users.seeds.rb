User.seed(:id,
          { id: 1, provider_id: 1, account: "Er111" },
          { id: 2, provider_id: 1, account: "Er222" },
          { id: 3, provider_id: 1, account: "Er333" },
          { id: 4, provider_id: 2, account: "Tm444" },
          { id: 5, provider_id: 2, account: "Tm555" },
          { id: 6, provider_id: 3, account: "It666", first_name: "Bill" , last_name: "Gates" }
)

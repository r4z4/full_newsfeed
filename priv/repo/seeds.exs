# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FullNewsfeed.Repo.insert!(%FullNewsfeed.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

password = System.fetch_env!("USER_PASSWORD")

alias FullNewsfeed.Repo
alias FullNewsfeed.Account.{User, Authorize}
alias FullNewsfeed.Core.{Hold}

Repo.insert_all(User, [
  %{id: "a9f44567-e031-44f1-aae6-972d7aabbb45", username: "admin", email: "admin@admin.com", role: :admin, hashed_password: Bcrypt.hash_pwd_salt(password), confirmed_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
  %{id: "b5f44567-e031-44f1-aae6-972d7aabbb45", username: "jimbo", email: "jimbo@jimbo.com", role: :subadmin, hashed_password: Bcrypt.hash_pwd_salt(password), confirmed_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
  %{id: "df18d5eb-e99e-4481-9e16-4d2f434a3711", username: "aaron", email: "aaron@aaron.com", role: :subadmin, hashed_password: Bcrypt.hash_pwd_salt(password), confirmed_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
  %{id: "67bbf29b-7ee9-48a4-b2fb-9a113e26ac91", username: "mn_user", email: "mn_user@example.com", role: :reader, hashed_password: Bcrypt.hash_pwd_salt(password), confirmed_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
  %{id: "459180af-49aa-48df-92e2-547be9283ac4", username: "wi_user", email: "wi_user@example.com", role: :reader, hashed_password: Bcrypt.hash_pwd_salt(password), confirmed_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
  %{id: "cf1ffc43-58a2-40e2-b08a-86bb2089ba64", username: "ia_user", email: "ia_user@example.com", role: :reader, hashed_password: Bcrypt.hash_pwd_salt(password), confirmed_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
  %{id: "4a501cb1-6e1c-45c1-8397-9bbd4a312044", username: "ca_user", email: "ca_user@example.com", role: :reader, hashed_password: Bcrypt.hash_pwd_salt(password), confirmed_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
  %{id: "549a7ba0-ea59-4333-bd01-eb4b3e4420f8", username: "il_user", email: "il_user@example.com", role: :reader, hashed_password: Bcrypt.hash_pwd_salt(password), confirmed_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
  %{id: "b2f44567-e031-44f1-aae6-972d7aabbb45", username: "tx_user", email: "tx_user@example.com", role: :reader, hashed_password: Bcrypt.hash_pwd_salt(password), confirmed_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()}
])

# Repo.insert_all(Hold, [
#   # Jim went to town and chose them all
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :follow, hold_cat: :race, hold_cat_id: "5d99c305-7d3e-4279-acc6-e90764139bc2", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :alert, hold_cat: :race, hold_cat_id: "5d99c305-7d3e-4279-acc6-e90764139bc2", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :star, hold_cat: :race, hold_cat_id: "5d99c305-7d3e-4279-acc6-e90764139bc2", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :bookmark, hold_cat: :race, hold_cat_id: "5d99c305-7d3e-4279-acc6-e90764139bc2", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},

#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :follow, hold_cat: :user, hold_cat_id: "a9f44567-e031-44f1-aae6-972d7aabbb45", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "df18d5eb-e99e-4481-9e16-4d2f434a3711", type: :follow, hold_cat: :user, hold_cat_id: "a9f44567-e031-44f1-aae6-972d7aabbb45", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "67bbf29b-7ee9-48a4-b2fb-9a113e26ac91", type: :follow, hold_cat: :user, hold_cat_id: "a9f44567-e031-44f1-aae6-972d7aabbb45", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b2f44567-e031-44f1-aae6-972d7aabbb45", type: :follow, hold_cat: :user, hold_cat_id: "a9f44567-e031-44f1-aae6-972d7aabbb45", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   # We got two friends - Jim holds Aaron & Aaron holds Jim
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :follow, hold_cat: :user, hold_cat_id: "df18d5eb-e99e-4481-9e16-4d2f434a3711", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "df18d5eb-e99e-4481-9e16-4d2f434a3711", type: :follow, hold_cat: :user, hold_cat_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   # Aaron chose 2
#   # Jim & Aaron subscribe to Pres Election
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :follow, hold_cat: :election, hold_cat_id: "bfe75d28-b2eb-4478-82f5-17828f9c82c6", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "df18d5eb-e99e-4481-9e16-4d2f434a3711", type: :follow, hold_cat: :election, hold_cat_id: "bfe75d28-b2eb-4478-82f5-17828f9c82c6", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   # Aaron chose 2
#   # Jim like Mike & Mirch & Sarah because WTF radio
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :vote, hold_cat: :candidate, hold_cat_id: "0e91778f-503f-4218-a801-c8bb7ff9498b", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :vote, hold_cat: :candidate, hold_cat_id: "0ce64757-3bf2-4779-99ca-3b5b35d59c4d", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :vote, hold_cat: :candidate, hold_cat_id: "049acd0a-427b-4096-8cd5-1ce59845649e", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :vote, hold_cat: :candidate, hold_cat_id: "09f131ac-818c-4058-b9ce-dc3b91794416", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   # Post Holds Jim & Aaron
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :upvote, hold_cat: :post, hold_cat_id: "956c5b4f-f1a1-42f0-b04d-bd80eddbe997", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :upvote, hold_cat: :post, hold_cat_id: "59e92082-6cc8-435d-9e71-59d3c89c9867", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :upvote, hold_cat: :post, hold_cat_id: "566f949a-be08-49e7-9c60-0c33d55b791b", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :upvote, hold_cat: :post, hold_cat_id: "1f310d22-6abb-4b9f-942a-53aafd7f2006", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :upvote, hold_cat: :post, hold_cat_id: "9de1ea76-ce5a-447f-a809-7b62dcbfa3a7", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "df18d5eb-e99e-4481-9e16-4d2f434a3711", type: :upvote, hold_cat: :post, hold_cat_id: "566f949a-be08-49e7-9c60-0c33d55b791b", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   # Thread Holds Jim & Aaron
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :share, hold_cat: :thread, hold_cat_id: "208272e9-1765-451f-9acb-79699ce5fc25", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "df18d5eb-e99e-4481-9e16-4d2f434a3711", type: :share, hold_cat: :thread, hold_cat_id: "208272e9-1765-451f-9acb-79699ce5fc25", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :like, hold_cat: :thread, hold_cat_id: "4fd6aa47-51da-4277-bca6-3a87b2153c20", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "df18d5eb-e99e-4481-9e16-4d2f434a3711", type: :like, hold_cat: :thread, hold_cat_id: "4fd6aa47-51da-4277-bca6-3a87b2153c20", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   # Favorites for Jim & Aaron
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :favorite, hold_cat: :thread, hold_cat_id: "208272e9-1765-451f-9acb-79699ce5fc25", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :favorite, hold_cat: :post, hold_cat_id: "566f949a-be08-49e7-9c60-0c33d55b791b", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "b5f44567-e031-44f1-aae6-972d7aabbb45", type: :favorite, hold_cat: :user, hold_cat_id: "df18d5eb-e99e-4481-9e16-4d2f434a3711", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()},
#   %{user_id: "df18d5eb-e99e-4481-9e16-4d2f434a3711", type: :favorite, hold_cat: :thread, hold_cat_id: "4fd6aa47-51da-4277-bca6-3a87b2153c20", updated_at: NaiveDateTime.local_now(), inserted_at: NaiveDateTime.local_now()}
# ])

#Authorization Roles
Repo.insert_all(Authorize, [
  # Jim went to town and chose them all
  %{id: Ecto.UUID.generate(),
        role: :reader,

        read: %{:user=> true, :candidate => true, :election => true, :ballot => true, :forum => true, :post => true, :thread => true, :race => true},
        edit: %{},
        create: %{},
        delete: %{},

        inserted_at: NaiveDateTime.local_now()},

  %{id: Ecto.UUID.generate(),
        role: :subadmin,

        read: %{:user=> true, :candidate => true, :election => true, :ballot => true, :forum => true, :post => true, :thread => true, :race => true},
        # permissions will allow editing of post, but still depend on ownership if can truly edit
        edit: %{:ballot => true, :post => true, :thread => true},
        create: %{:post => true, :thread => true},
        delete: %{:post => true, :thread => true},

        inserted_at: NaiveDateTime.local_now()},

  %{id: Ecto.UUID.generate(),
        role: :admin,

        read: %{:user=> true, :candidate => true, :election => true, :ballot => true, :forum => true, :post => true, :thread => true, :race => true},
        edit: %{:user=> true, :candidate => true, :election => true, :ballot => true, :forum => true, :post => true, :thread => true, :race => true},
        create: %{:user=> true, :candidate => true, :election => true, :ballot => true, :forum => true, :post => true, :thread => true, :race => true},
        delete: %{:user=> true, :candidate => true, :election => true, :ballot => true, :forum => true, :post => true, :thread => true, :race => true},

        inserted_at: NaiveDateTime.local_now()},

  # %{id: Ecto.UUID.generate(),
  #       role: :candidate,

  #       read: %{:candidate => true},
  #       edit: %{:candidate => true},
  #       create: %{:forum => true, :post => true, :thread => true, :race => true},
  #       delete: %{},

  #       updated_at: NaiveDateTime.local_now(),
  #       inserted_at: NaiveDateTime.local_now()}
])

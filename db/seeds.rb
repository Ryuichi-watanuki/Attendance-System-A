# ユーザー
User.create!(name:  "管理者",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             affiliation: "管理者",
             basic_time: Time.zone.parse("04:00"),
             specified_start_time: Time.zone.parse("14:00"),
             specified_end_time: Time.zone.parse("18:00"),
             card_id: "cd1000",
             admin:     true,
             boss:      true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "バラライカ",
             email: "example2@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             affiliation: "大尉",
             basic_time: Time.zone.parse("02:00"),
             specified_start_time: Time.zone.parse("18:00"),
             specified_end_time: Time.zone.parse("20:00"),
             card_id: "cd2000",
             boss:      true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "リーダー",
             email: "example3@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             affiliation: "上長A",
             basic_time: Time.zone.parse("04:00"),
             specified_start_time: Time.zone.parse("08:00"),
             specified_end_time: Time.zone.parse("12:00"),
             card_id: "cd3000",
             boss:      true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "ボス",
             email: "example4@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             affiliation: "上長B",
             basic_time: Time.zone.parse("04:00"),
             specified_start_time: Time.zone.parse("12:00"),
             specified_end_time: Time.zone.parse("16:00"),
             card_id: "cd4000",
             boss:      true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "テスト一般ユーザ用",
             email: "example5@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             affiliation: "一般",
             basic_time: Time.zone.parse("04:00"),
             specified_start_time: Time.zone.parse("12:00"),
             specified_end_time: Time.zone.parse("16:00"),
             card_id: "cd9999",
             activated: true,
             activated_at: Time.zone.now)

# coding: utf-8

30.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "foobar"
  affiliation = "一般"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               affiliation:        affiliation,
               basic_time: Time.zone.parse("07:30"),
               specified_start_time: Time.zone.parse("9:30"),
               specified_end_time: Time.zone.parse("18:00"),
               activated: true,
               activated_at: Time.zone.now)
end

Base.create!(base_name: "ココット村")
Base.create!(base_name: "ポッケ村")
Base.create!(base_name: "ユクモ村")
# ユーザー
User.create!(name:  "綿貫　竜一",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             affiliation: "管理者",
             basic_time: Time.zone.parse("07:30"),
            #  specified_working_time: Time.parse("2018/04/07 08:00"),
             admin:     true,
             boss:      true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "ボス",
             email: "boss@railstutorial.org",
             password:              "bossboss",
             password_confirmation: "bossboss",
             affiliation: "上長",
             basic_time: Time.zone.parse("07:30"),
            #  specified_working_time: Time.parse("2018/04/07 08:00"),
             boss:      true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(name:  "テスト一般ユーザ用",
             email: "example2@railstutorial.org",
             password:              "foobar2",
             password_confirmation: "foobar2",
             affiliation: "一般",
             basic_time: Time.zone.parse("07:30"),
            #  specified_working_time: Time.parse("2018/04/07 08:00"),
             activated: true,
             activated_at: Time.zone.now)



# coding: utf-8

30.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  affiliation = "一般ユーザー"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               affiliation:        affiliation,
               basic_time: Time.zone.parse("07:30"),
            #   specified_working_time: Time.parse("2018/04/07 08:00"),
               activated: true,
               activated_at: Time.zone.now)
end

Base.create!(base_name: "ココット村")
Base.create!(base_name: "ポッケ村")
Base.create!(base_name: "ユクモ村")
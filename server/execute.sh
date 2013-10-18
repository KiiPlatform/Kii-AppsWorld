curl -v -X POST \
  -H "content-type: application/json" \
  -H "x-kii-appid:fa71e7e2" \
  -H "x-kii-appkey:70577e03f949a31615ecd8c1241fcee8" \
  -d '{"username":"name_of_my_friend", "password":"password_for_my_friend"}' \
  "https://api.kii.com/api/apps/fa71e7e2/server-code/versions/current/feed"

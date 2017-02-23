# crystal_sdk

This gem provides access to Crystal, the world's largest and most accurate personality database!

Here's how to install it:
```bash
$ gem install crystal_sdk
```

Here's how you use it:

```ruby
require 'crystal_sdk'

CrystalSDK.key = "OrgKey"

begin
  CrystalSDK::Profile.search({
    first_name: "Drew",
    last_name: "D'Agostino"
  })

rescue CrystalSDK::Profile::NotFoundError
  print "No profile was found"

rescue CrystalSDK::Profile::NotFoundYetError
  print "Profile search exceeded time limit"

rescue CrystalSDK::Profile::RateLimitHitError
  print "The organization's API rate limit was hit"

rescue CrystalSDK::Profile::NotAuthedError
  print "Org key was invalid"

rescue StandardError => e
  print "Unexpected error occurred: #{e}"

end
```

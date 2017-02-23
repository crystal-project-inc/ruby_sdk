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
  profile = CrystalSDK::Profile.search({
    first_name: "Drew",
    last_name: "D'Agostino"
  })

  print "First Name: #{profile.info.first_name}"
  print "Last Name: #{profile.info.last_name}"
  print "Predicted DISC Type: #{profile.info.disc_type}"
  print "Prediction Confidence: #{profile.info.confidence}"

  print "Recommendations: #{profile.recommendations}"

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

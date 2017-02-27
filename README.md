# Crystal Ruby SDK

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
    last_name: "D'Agostino",
    email: "drew@crystalknows.com",
    company_name: "Crystal",
    location: "Nashville, TN",
    text_sample: "I, Drew, the founder of Crystal, think that ...",
    text_type: "various"
  })

  print "Profile found!"
  print "First Name: #{profile.info.first_name}"
  print "Last Name: #{profile.info.last_name}"
  print "Predicted DISC Type: #{profile.info.disc_type}"
  print "Prediction Confidence: #{profile.info.confidence}"
  print "Personality Overview: #{profile.info.overview}"

  print "Recommendations: #{profile.recommendations}"

rescue CrystalSDK::Profile::NotFoundError
  print "No profile was found"

rescue CrystalSDK::Profile::NotFoundYetError => e
  print "Profile search exceeded time limit: #{e.request.id}"

rescue CrystalSDK::Profile::RateLimitHitError
  print "The organization's API rate limit was hit"

rescue CrystalSDK::Profile::NotAuthedError => e
  print "Org key was invalid: #{e.token}"

rescue StandardError => e
  print "Unexpected error occurred: #{e}"

end
```

## Asynchronous Flow

When requesting large amounts of profiles, or when wanting to have more fine-grained control over performance, we recommend using our asynchronous flow. It allows us to process your requests in parallel and get the information back to you more quickly. There are a few options for using this capability.

### Option 1: Wait, then fetch

The first option is to wait a period of time and check if the request is finished:

```ruby
query = { first_name: "Drew", ... }
profile_request = CrystalSDK::Profile::Request.from_search(query)

sleep(10)

if profile_request.did_finish?
  begin
    profile = profile_request.profile
    ...

  rescue CrystalSDK::Profile::NotFoundError
    print "No profile was found"

  rescue CrystalSDK::Profile::NotAuthedError => e
    print "Org key was invalid: #{e.token}"

  rescue StandardError => e
    print "Unexpected error: #{e}

  end
end
```

This option allows you to set up a series of requests and then wait a reasonable amount of time before they complete. It's the simplest option that would allow you to benefit from our parallel processing while not adding much complexity.

### Option 2: Polling
The option we use internally in the SDK, is to poll for request information periodically until a set timeout has been reached:

```ruby
MAX_RETRIES = 10
PAUSE_IN_SECONDS = 3

query = { first_name: "Drew", ... }
request = CrystalSDK::Profile::Request.from_search(query)
profile = nil

MAX_RETRIES.times do
  sleep(PAUSE_IN_SECONDS) and next unless request.did_finish?

  profile = Profile.from_request(request) if request.did_find_profile?
  break
end

profile
```

Polling can be extended to poll for multiple profiles. It gives the efficiency of our parallel processing, while writing code that behaves synchronously.

This option is great if you want information as fast as possible while keeping open network connections and code complexity to a minimum. It is especially useful if you are requesting multiple profiles and can process the profiles one at a time, as each individual profile comes in (as opposed to waiting for all of them to come in before continuing).


### Option 3: Background Processing

Sometimes, it isn't important to have the profile information immediately. Especially when dealing with larger jobs or passive data enrichment. In that case, we allow you to save the Request ID and pull information from the request at a later time via this ID.

```ruby

# Send the request to Crystal
profile_request = CrystalSDK::Profile::Request.from_search(query)

# Pull out the Profile Request ID (string)
profile_request_id = profile_request.id

# Save the Request ID somewhere (to a database or background job, for example)
...

# Later, pull up the Request ID and pull information about it
backgrounded_request = CrystalSDK::Profile::Request.new(profile_request_id)

if backgrounded_request.did_finish? && backgrounded_request.did_find_profile?
  profile = backgrounded_request.profile
  ...
end
```

We try and store your request for a few days after the request has been started. Your Request ID should work when you try to pull information from it - for that period of time.


## Contributing

- Clone the repository:
  `git clone git@github.com:crystal-project-inc/ruby_sdk.git`

- Run rspec tests:
  
  `rspec`

- Open up an IRB console with the gem loaded to play around with it:

  `rake console`

- Make a code change

- Check that the tests still pass

- Make a pull request!

We will review the Pull Request to make sure that it does not break the external specification of the gem and that it fits with the overall mission of the SDK!

We also encourage people to build further libraries that utilize our SDK and extend the use of the Connect API!

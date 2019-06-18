# CD4PE Test Plan
This document outlines the functional test cases to be executed against CD4PE.

_NOTE_: Web interfaces should be security tested via an OWASP guide such as [ZAP](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project)


## Installation


### Via PE Integrations 2019.1.x


#### Environment Setup
1. Deploy PE 2019.1.0
   * TODO: Detailed steps here
1. Provision node to be dedicated to CD4PE to run on
   * TODO: Detailed steps here
1. Add node to PE; Accept key; run puppet on node
   * TODO: Detailed steps here


#### Basic
_Setup_: In the PE console, navigate to Integrations:

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify host field - must be filled in | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify host field - must be managed host | 1. Fill field with non-managed host value <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify Administrator email field - must be filled in | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify Administrator email field - should accept email address with TLD | 1. Fill field with '!def!xyz%abc@example.org' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | https://tools.ietf.org/html/rfc3696 |
| Verify Administrator email field - should accept email address without TLD | 1. Fill field with '!def!xyz%abc@example' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | https://tools.ietf.org/html/rfc3696 | |
| Verify Administrator email field - should accept UTF-8 in local | 1. Fill field with email '©®@a.b' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | https://tools.ietf.org/html/rfc6531 | |
| Verify Administrator email field - should reject malformed email address | 1. Fill field with "evil'ex" <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify Administrator email field - should accept local of 64 chars | 1. Fill field with 'MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlis@example.org' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | |
| Verify Administrator email field - local must not exceed 64 chars | 1. Fill field with 'MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistment@example.org' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | https://tools.ietf.org/html/rfc3696 |
| Verify Administrator email field - should accept domain of 255 chars | 1. Fill field with 'user@MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistmentVaudevilleLatishaDecriedJovianLenghtwiseTroubleshooterClamberCaterersAnthropologistGarbedSlicerExpediencyBroodingPilafRiddlesForthcomingUnkindlierTitanicAlzheimerDoubterDumpedFifesMe.org' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | |
| Verify Administrator email field - domain must not exceed 255 chars | 1. Fill field with 'user@MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistmentVaudevilleLatishaDecriedJovianLenghtwiseTroubleshooterClamberCaterersAnthropologistGarbedSlicerExpediencyBroodingPilafRiddlesForthcomingUnkindlierTitanicAlzheimerDoubterDumpedFifesMel.org' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify Administrator password field - minimum (1)  | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify Administrator password field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify Administrator password field - character set  | 1. Fill field with accepted character set <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | |


#### Advanced Options
_Setup_: In the PE console, navigate to Integrations:

|  Test Name |  Steps |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify resolvable_hostname parameter - should override certname | 1. Create CD4PE host with unresolvable certname and resolvable altname <BR> 2. Add resolvable_hostname parameter with altname value <BR> 3. Fill in other fields 4. Click Run Job button | Install should succeed | |
| Verify cd4pe_image parameter - should use specified image | 1. Add cd4pe_image parameter with 'hello-world' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail reporting usage of 'hello-world' docker image | |
| Verify cd4pe_version parameter - should install older cd4pe version | 1. Add cd4pe_version parameter with '1.1.1' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and installed version should be '1.1.1' | |
| Verify cd4pe_version parameter - should provide understandable errror | 1. Add cd4pe_version parameter with '99.99.99' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that specified version cannot be found | |


##### Database Options
_Setup_: In the PE console, navigate to Integrations:

_Parameters_:

* manage_database (Set this parameter to false to use DynamoDB, or true to use MySQL.)
* db_provider (Enter mysql to use MySQL. Do not set this parameter if using DynamoDB.)
* db_host (Required for DynamoDB users, optional for MySQL users.)
* db_name (Required for DynamoDB users, optional for MySQL users.)
* db_pass (Required for DynamoDB users, optional for MySQL users.) You must set
  the root_password parameter to Sensitive in Hiera for this parameter to work properly.
* db_port (Required for DynamoDB users, optional for MySQL users.)
* db_prefix

###### DynamoDB
_Setup_:
* Create DynamoDB instance
  * TODO: Detailed steps here
  * Set db_host=foo
  * Set db_name=cd4pe
  * Set db_pass=bar
  * Set db_port=8000
  * Set `root_password` as sensitive in hiera
    ```
    ---
    lookup_options:
      '^cd4pe::root_config::root_password$':
        convert_to: 'Sensitive'
    ```


|  Test Name |  Steps |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify manage_database parameter - should enable DDB when false | 1. Add manage_database parameter with 'false' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Add db_port parameter with '8000' value <BR> 6. Fill in other fields <BR> 7. Click Run Job button | Install should succeed and DDB should be used for storage | |
| Verify manage_database parameter - should enable DDB when empty | 1. Add manage_database parameter with '' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Add db_port parameter with '8000' value <BR> 6. Fill in other fields <BR> 7. Click Run Job button | Install should succeed and DDB should be used for storage | |
| Verify manage_database parameter - should provide understandable error (true) | 1. Add manage_database parameter with 'true' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Add db_port parameter with '8000' value <BR> 6. Fill in other fields <BR> 7. Click Run Job button | Install should fail, reporting that `manage_database` should not be set if `db_{host,name,pass,port}` are set | |
| Verify db_provider parameter - should provide understandable error (DDB) | 1. Add db_provider parameter with 'dynamodb' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Add db_port parameter with '8000' value <BR> 6. Fill in other fields <BR> 7. Click Run Job button | Install should fail, reporting that `db_provider` should not be set if `manage_database` is `true`. | UX: Should this accept values of `ddb` and/or `dynamodb`? |
| Verify db_provider parameter - should provide understandable error (unsupported) | 1. Add db_provider parameter with "evil'ex" value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Add db_port parameter with '8000' value <BR> 6. Fill in other fields <BR> 7. Click Run Job button | Install should fail, reporting that `db_provider` should not be set if `manage_database` is `true`. | UX: Should this report unsupported database engine? |
| Verify db_host parameter - should succeed when available | 1. Add db_host parameter with 'foo' value <BR> 2. Add db_name parameter with 'cd4pe' value <BR> 3. Add db_pass parameter with 'bar' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should succeed and DDB should be used for storage on host 'foo' |
| Verify db_host parameter - should provide understandable error (unset) | 1. Do not add db_host parameter <BR> 2. Add db_name parameter with 'cd4pe' value <BR> 3. Add db_pass parameter with 'bar' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that `db_host` must be set when??  | What is the key indicator that dynamodb is the desired provider since `db_provider` does not support this value? |
| Verify db_host parameter - should provide understandable error (unavailable) | 1. Add db_host parameter with 'bogus' value <BR> 2. Add db_name parameter with 'cd4pe' value <BR> 3. Add db_pass parameter with 'bar' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that hostname is unreachable |
| Verify db_host parameter - should provide understandable error (invalid) | 1. Add db_host parameter with '!@#$%^&?' value <BR> 2. Add db_name parameter with 'cd4pe' value <BR> 3. Add db_pass parameter with 'bar' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that hostname is invalid (support schema) | Do we support internationalized domains (binary) as per https://tools.ietf.org/html/rfc2181#section-11 ?? |
| Verify db_name parameter - should succeed when available | 1. Add db_name parameter with 'cd4pe' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_pass parameter with 'bar' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should succeed and DDB should be used for storage using 'cd4pe' database | |
| Verify db_name parameter - should provide understandable error (unset) | 1. Do not add db_name parameter <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_pass parameter with 'bar' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that `db_name` must be set when?? | What is the key indicator that dynamodb is the desired provider since `db_provider` does not support this value? |
| Verify db_name parameter - should provide understandable error (unavailable) | 1. Add db_name parameter with 'bogus' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_pass parameter with 'bar' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that `db_name` is not available on given host | |
| Verify db_name parameter - should provide understandable error (invalid) | 1. Add db_name parameter with _TODO: Determine invalid value 'invalid'_ value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_pass parameter with 'bar' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that `db_name` is not available on given host | [aws docs](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.NamingRulesDataTypes.html) |
| Verify db_pass parameter - should succeed when available | 1. Add db_pass parameter with 'bar' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should succeed and DDB should be used for storage using 'cd4pe' database | |
| Verify db_pass parameter - should provide understandable error (unset) | 1. Do not add db_pass parameter <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that `db_pass` must be set when?? |  What is the key indicator that dynamodb is the desired provider since `db_provider` does not support this value? |
| Verify db_pass parameter - should provide understandable error (failed auth) | 1. Add db_pass parameter with 'bogus' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_port parameter with '8000' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that could not connect to database |
| Verify db_port parameter - should succeed when available | 1. Add db_port parameter with '8000' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should succeed and DDB should be used for storage using 'cd4pe' database |
| Verify db_port parameter - should provide understandable error (unset) | 1. Do not add db_port parameter <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that `db_port` must be set when?? | What is the key indicator that dynamodb is the desired provider since `db_provider` does not support this value? |
| Verify db_port parameter - should provide understandable error (unavailable) | 1. Add db_port parameter with '21' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that could not connect to host | |
| Verify db_port parameter - should provide understandable error (invalid) | 1. Add db_port parameter with 'invalid' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that `db_port` only supports port numbers in [specified range] |


###### MySQL
_Setup_:
* Create MySQL instance
  * TODO: Detailed steps here
  * Set db_host=foo
  * Set db_name=cd4pe
  * Set db_pass=bar
  * Set db_port=3306
  * Set `root_password` as sensitive in hiera
    ```
    ---
    lookup_options:
      '^cd4pe::root_config::root_password$':
        convert_to: 'Sensitive'
    ```

|  Test Name |  Steps |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify manage_database parameter - should only allow true/false | 1. Add manage_database parameter with "evil'ex" value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that true/false value must be supplied | |
| Verify manage_database parameter - should provide understandable error (no provider) | 1. Add manage_database parameter with 'true' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that `db_provider` must be specified | |
| Verify manage_database parameter - should provide understandable error (false) | 1. Add manage_database parameter with 'false' value <BR> 2. Add db_provider parameter with 'mysql' value <BR> 3. Fill in other fields <BR> 4. Click Run Job button | Install should fail, reporting that parameter must be `false` wnen `db_provider` is set to 'mysql' | |
| Verify manage_database parameter - true should enable MySQL when provider set (with `db_provider`; without `db_{host,name,pass,port}`) | 1. Add manage_database parameter with 'true' value <BR> 2. Add db_provider parameter with 'mysql' value <BR> 3. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and MySQL should be used for storage | UX/Docs: Can this be inferred by the `db_provider` value and not have to be set? |
| Verify db_host parameter - should succeed when available | 1. Add db_host parameter with 'foo' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'mysql' value <BR> 4. Add db_name parameter with 'cd4pe' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '3306' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should succeed and MySQL should be used for storage on host 'foo' |
| Verify db_host parameter - (unset) | | | What is the expected behaviour since this is optional? |
| Verify db_host parameter - should provide understandable error (unavailable) | 1. Add db_host parameter with 'bogus' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'mysql' value <BR> 4. Add db_name parameter with 'cd4pe' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '3306' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that hostname is unreachable |
| Verify db_host parameter - should provide understandable error (invalid) | 1. Add db_host parameter with '!@#$%^&?' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'mysql' value <BR> 4. Add db_name parameter with 'cd4pe' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '3306' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that hostname is invalid (support schema) | Do we support internationalized domains (binary) as per https://tools.ietf.org/html/rfc2181#section-11 ?? |
| Verify db_name parameter - should succeed when available | 1. Add db_name parameter with 'cd4pe' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'mysql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '3306' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should succeed and MySQL should be used for storage using 'cd4pe' database | |
| Verify db_name parameter - (unset) | | | What is the expected behaviour since this is optional? |
| Verify db_name parameter - should provide understandable error (unavailable) | 1. Add db_name parameter with 'bogus' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'mysql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '3306' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that `db_name` is not available on given host | |
| Verify db_name parameter - should provide understandable error (invalid) | 1. Add db_name parameter with _TODO: Determine invalid value 'invalid'_ value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'mysql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '3306' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that `db_name` is not available on given host | |
| Verify db_pass parameter - should succeed when available | 1. Add db_pass parameter with 'bar' value <BR>  2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'mysql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_name parameter with 'cd4pe' value <BR> 6. Add db_port parameter with '3306' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should succeed and MySQL should be used for storage using 'cd4pe' database | |
| Verify db_pass parameter - (unset) | | | What is the expected behaviour since this is optional? |
| Verify db_pass parameter - should provide understandable error (failed auth) | 1. Add db_pass parameter with 'bogus' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'mysql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_name parameter with 'cd4pe' value <BR> 6. Add db_port parameter with '3306' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that could not connect to database |
| Verify db_port parameter - should succeed when available | 1. Add db_port parameter with '3306' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'mysql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_name parameter with 'cd4pe' value <BR> 6. Add db_pass parameter with 'bar' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should succeed and MySQL should be used for storage using 'cd4pe' database |
| Verify db_port parameter - (unset) | | | What is the expected behaviour since this is optional? |
| Verify db_port parameter - should provide understandable error (invalid) | 1. Add db_port parameter with 'invalid' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'mysql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_name parameter with 'cd4pe' value <BR> 6. Add db_pass parameter with 'bar' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that `db_port` only supports port numbers in [specified range] |


###### PostgreSQL
_Setup_:
* Create PostgreSQL instance
  * TODO: Detailed steps here
  * Set db_host=foo
  * Set db_name=cd4pe
  * Set db_pass=bar
  * Set db_port=5432
  * Set `root_password` as sensitive in hiera
    ```
    ---
    lookup_options:
      '^cd4pe::root_config::root_password$':
        convert_to: 'Sensitive'
    ```

|  Test Name |  Steps |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify manage_database parameter - should only allow true/false | 1. Add manage_database parameter with "evil'ex" value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that true/false value must be supplied | |
| Verify manage_database parameter - should provide understandable error (no provider) | 1. Add manage_database parameter with 'true' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that `db_provider` must be specified | |
| Verify manage_database parameter - should provide understandable error (false) | 1. Add manage_database parameter with 'false' value <BR> 2. Add db_provider parameter with 'postgresql' value <BR> 3. Fill in other fields <BR> 4. Click Run Job button | Install should fail, reporting that parameter must be `false` wnen `db_provider` is set to 'postgresql' | |
| Verify manage_database parameter - true should enable PostgreSQL when provider set (with `db_provider`; without `db_{host,name,pass,port}`) | 1. Add manage_database parameter with 'true' value <BR> 2. Add db_provider parameter with 'postgresql' value <BR> 3. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and PostgreSQL should be used for storage | UX/Docs: Can this be inferred by the `db_provider` value and not have to be set? |
| Verify db_host parameter - should succeed when available | 1. Add db_host parameter with 'foo' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'postgresql' value <BR> 4. Add db_name parameter with 'cd4pe' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '5432' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should succeed and PostgreSQL should be used for storage on host 'foo' |
| Verify db_host parameter - (unset) | | | What is the expected behaviour since this is optional? |
| Verify db_host parameter - should provide understandable error (unavailable) | 1. Add db_host parameter with 'bogus' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'postgresql' value <BR> 4. Add db_name parameter with 'cd4pe' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '5432' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that hostname is unreachable |
| Verify db_host parameter - should provide understandable error (invalid) | 1. Add db_host parameter with '!@#$%^&?' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'postgresql' value <BR> 4. Add db_name parameter with 'cd4pe' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '5432' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that hostname is invalid (support schema) | Do we support internationalized domains (binary) as per https://tools.ietf.org/html/rfc2181#section-11 ?? |
| Verify db_name parameter - should succeed when available | 1. Add db_name parameter with 'cd4pe' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'postgresql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '5432' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should succeed and PostgreSQL should be used for storage using 'cd4pe' database | |
| Verify db_name parameter - (unset) | | | What is the expected behaviour since this is optional? |
| Verify db_name parameter - should provide understandable error (unavailable) | 1. Add db_name parameter with 'bogus' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'postgresql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '5432' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that `db_name` is not available on given host | |
| Verify db_name parameter - should provide understandable error (invalid) | 1. Add db_name parameter with _TODO: Determine invalid value 'invalid'_ value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'postgresql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '5432' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that `db_name` is not available on given host | |
| Verify db_pass parameter - should succeed when available | 1. Add db_pass parameter with 'bar' value <BR>  2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'postgresql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_name parameter with 'cd4pe' value <BR> 6. Add db_port parameter with '5432' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should succeed and PostgreSQL should be used for storage using 'cd4pe' database | |
| Verify db_pass parameter - (unset) | | | What is the expected behaviour since this is optional? |
| Verify db_pass parameter - should provide understandable error (failed auth) | 1. Add db_pass parameter with 'bogus' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'postgresql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_name parameter with 'cd4pe' value <BR> 6. Add db_port parameter with '5432' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that could not connect to database |
| Verify db_port parameter - should succeed when available | 1. Add db_port parameter with '5432' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'postgresql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_name parameter with 'cd4pe' value <BR> 6. Add db_pass parameter with 'bar' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should succeed and PostgreSQL should be used for storage using 'cd4pe' database |
| Verify db_port parameter - (unset) | | | What is the expected behaviour since this is optional? |
| Verify db_port parameter - should provide understandable error (invalid) | 1. Add db_port parameter with 'invalid' value <BR> 2. Add manage_database parameter with 'true' value <BR> 3. Add db_provider parameter with 'postgresql' value <BR> 4. Add db_host parameter with 'foo' value <BR> 5. Add db_name parameter with 'cd4pe' value <BR> 6. Add db_pass parameter with 'bar' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that `db_port` only supports port numbers in [specified range] |


##### Port Mapping Options
|  Test Name |  Steps |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify agent_service_port parameter - should bind to given port | 1. Add agent_service_port parameter with '7010' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and service should be bound to port '7010' | |
| Verify agent_service_port parameter - should provide understandable error (previously bound) | 1. Add agent_service_port parameter with '22' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail reporting that port is already bound | |
| Verify agent_service_port parameter - should provide understandable error (invalid) | 1. Add agent_service_port parameter with 'invalid' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that parameter only supports port numbers in [specified range] | |
| Verify backend_service_port parameter - should bind to given port | 1. Add backend_service_port parameter with '8010' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and service should be bound to port '8010' | |
| Verify backend_service_port parameter - should provide understandable error (previously bound) | 1. Add backend_service_port parameter with '22' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail reporting that port is already bound | |
| Verify backent_service_port parameter - should provide understandable error (invalid) | 1. Add backend_service_port parameter with 'invalid' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that parameter only supports port numbers in [specified range] | |
| Verify web_ui_port parameter - should bind to given port | 1. Add web_ui_port parameter with '80' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and service should be bound to port '80' | |
| Verify web_ui_port parameter - should provide understandable error (previously bound) | 1. Add web_ui_port parameter with '22' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail reporting that port is already bound | |
| Verify web_ui_port parameter - should provide understandable error (invalid) | 1. Add web_ui_port parameter with 'invalid' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that parameter only supports port numbers in [specified range] | |


##### Other Options
_Parameters_:
* cd4pe_docker_extra_params
* analytics

|  Test Name |  Steps |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify cd4pe_docker_extra_params parameter - should pass value to docker command | 1. Add cd4pe_docker_extra_params parameter with '["--name=foobar"]' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and the docker instance should be named 'foobar' | |
| Verify analytics parameter - should enable analytics if true | 1. Add analytics parameter with 'true' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and analytics should be enabled | |
| Verify analytics parameter - should disable analytics if false | 1. Add analytics parameter with 'false' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and analytics should be disabled | |
| Verify analytics parameter - should provide understandable error (invalid) | 1. Add analytics parameter with "evil'ex" value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail reporting that "evil'ex" is not a valid value for analytics | |


### Via PE Integrations (2019.0.x or 2018.1.x)
TBD


### Via CD4PE Module
TBD


### Via OVA
TBD


### Via Docker
TBD


## Initial Login


### Configure endpoint

http://ip-10-227-0-212.amz-dev.puppet.net:8080/configure
A test license can be downloaded locally from:
https://github.com/puppetlabs/pipelines-self-paced/blob/master/cd4pe/assets/license.json

  * Test input
  * Test reload scenarios
     * FAILED: When license has already been uploaded, the configure endpoint
       still prompts for license.
     * FAILED: Uploading duplicate license cannot be completed. Replies with the
       following error when trying to accept the License Aggreement.
```
You do not have access to this operation. Please contact an administrator to gain access.
```
https://tickets.puppetlabs.com/browse/CDPE-1639

This endpoint provides several forms for configuration:
  * Endpoints
  * Storage
  * License

|  Test Name |  Steps |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify license - should provide understandable error (invalid json) | 1. Create empty text file on local machine <BR> 2. Navigate to http://<cd4pe-instance.:<web-ui-port>/configure  <BR> 3. Click 'License' 4. Click Choose button 5. Select file 6. Click Submit License button | License application should fail, reporting that license file is invalid  | |
| Verify license - should provide understandable error (invalid license schema) | 1. Create json file on local machine with contents of '{}' <BR> 2. Navigate to http://<cd4pe-instance.:<web-ui-port>/configure  <BR> 3. Click 'License' 4. Click Choose button 5. Select file 6. Click Submit License button | License application should fail, reporting that license file is invalid  | |
| Verify license - should provide understandable error (invalid license) | 1. Create json file on local machine with contents of '{ "document": { "address": "", "companyName": "", "contactEmail": "", "contactName": "", "created": "", "eula": "", "expiration": "", "id": "", "nodes": "", "projects": "", "servers": "", "type": "" }, "signature": "", "eula": "" }' <BR> 2. Navigate to http://<cd4pe-instance.:<web-ui-port>/configure  <BR> 3. Click 'License' 4. Click Choose button 5. Select file 6. Click Submit License button | License application should fail, reporting that license is invalid  | |
| Verify login - should reject invalid credentials (root) | 1. Submit valid license file 2. Click 'or continue to manage configurations as root' 3. Enter 'foo' in Email field 4. Enter 'bar' in Password field 5. Click  Sign In button | Login should fail, reporting that credentials are unknown | |
| Verify login - should accept valid credentials (root) | 1. Submit valid license file 2. Click 'or continue to manage configurations as root' 3. Enter email used during installation in Email field 4. Enter password used during installation in Password field 5. Click  Sign In button | Login should succeed | _UX:_ The usage of "root" is not used during installation via integrations.  During installation, this is refered to as the "Continuous Delivery for PE administrator" account.  These terms should be consistent. |


### Create initial user
_Setup_: Navigate to http://<cd4pe-instance.:<web-ui-port>/signup

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify required fields - must be filled in | 1. Leave all fields blank <BR> 2. Click Sign Up button | Account creation should fail, reporting that the required fields have not been populated | |
| Verify First Name field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Sign up button | Account creation should fail, reporting that the field must be populated | |
| Verify First Name field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting the maximum acceptable length | |
| Verify First Name field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify First Name field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Last Name field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Sign up button | Account creation should fail, reporting that the field must be populated | |
| Verify Last Name field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting the maximum acceptable length | |
| Verify Last Name field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Last Name field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Email field - must be filled in | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Sign up button | Account creation should fail, reporting that the field must be populated | |
| Verify Email field - should accept email address with TLD | 1. Fill field with '!def!xyz%abc@example.org' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Email field - should accept email address without TLD | 1. Fill field with '!def!xyz%abc@example' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Email field - should accept UTF-8 in local | 1. Fill field with email '©®@a.b' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Email field - should reject malformed email address | 1. Fill field with "evil'ex" <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting that the field must be valid email | |
| Verify Email field - should accept local of 64 chars | 1. Fill field with 'MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlis@example.org' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Email field - local must not exceed 64 chars | 1. Fill field with 'MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistment@example.org' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting that the field must be valid email | |
| Verify Email field - should accept domain of 255 chars | 1. Fill field with 'user@MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistmentVaudevilleLatishaDecriedJovianLenghtwiseTroubleshooterClamberCaterersAnthropologistGarbedSlicerExpediencyBroodingPilafRiddlesForthcomingUnkindlierTitanicAlzheimerDoubterDumpedFifesMe.org' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Email field - domain must not exceed 255 chars | 1. Fill field with 'user@MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistmentVaudevilleLatishaDecriedJovianLenghtwiseTroubleshooterClamberCaterersAnthropologistGarbedSlicerExpediencyBroodingPilafRiddlesForthcomingUnkindlierTitanicAlzheimerDoubterDumpedFifesMel.org' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting that the field must be valid email | |
| Verify Username field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Sign up button | Account creation should fail, reporting that the field must be populated | |
| Verify Username field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting the maximum acceptable length | |
| Verify Username field - character set (invalid)  | 1. Fill field with string containing invalid characters <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting what the valid character set is | |
| Verify Username field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Password field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Sign up button | Account creation should fail, reporting that the field must be populated | |
| Verify Password field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting the maximum acceptable length | |
| Verify Password field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Password field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |


## Create User Account
TBD


## Source Control Integration


### Azure
TBD


### Bitbucket
TBD


### GitHub
_Setup_:
* [Create GitHub OAuth](https://developer.github.com/apps/building-oauth-apps/creating-an-oauth-app/)
* Navigate to http://<cd4pe-instance.:<web-ui-port>/root/settings
* Click Integrations link

_DOCS_: [Docs](https://puppet.com/docs/continuous-delivery/2.x/integrations.html#integrate-github)
indicate that CD4PE provides the "Authorization callback URL" for the OAuth App,
but no guidance is provided for the "Homepage URL".


|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify integration - valid | 1. Fill Client ID field with valid value <BR> 2. Fill Client Secret field with valid value <BR> 3. Click Add link 4. Click Add Integration button | Integration should succeed (How can integration be verified?). | _DOCS_: GitHub authorization follow up does not occur. Terminology in docs does not match current UI.  _UX_: The done button after this interaction seems unnecessary |
| Verify integration - invalid | 1. Fill Client ID field with invalid value <BR> 2. Fill Client Secret field with invalid value <BR> 3. Click Add link 4. Click Add Integration button | Integration should fail, reporting unable to authenticate with OAuth application | |
| Verify integration - removal | 1. Fill Client ID field with valid value <BR> 2. Fill Client Secret field with valid value <BR> 3. Click Add link 4. Click Remove link 5. Click Remove Integration button | Integration should be successfully removed | |
| Verify Client ID field - minimum (1)  | 1. Leave Client ID field blank <BR> 2. Fill Client Secret field with valid value <BR> 3. Click Add link | Add link should be disabled | |
| Verify Client Secret field - minimum (1)  | 1. Fill Client ID field with valid value <BR> 2. Leave Client Secret field blank <BR> 3. Click Add link | Add link should be disabled | |

_BUG_: Cannot reproduce. The application successfully processes invalid integration values. I was then not able to remove them in a subsequent transaction.
```
Please contact the site administrator for support along with errorId=[md5:1271bc29cb3b5fcc912da3c4154673bb 2019-06-10 16:57 06y2xeofaekf30tbgl2xt5qsng]
```

### GitHub Enterprise
TBD


### GitLab
TBD


## Control Repo Setup
TBD


## Add Job Hardware
TBD


## Pipelines
TBD


## Code Deploy
TBD


## Impact Analysis
TBD

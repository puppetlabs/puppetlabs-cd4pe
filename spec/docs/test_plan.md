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
TBD


## Create User Account
TBD


## Source Control Integration


### Azure
TBD


### Bitbucket
TBD


### GitHub
TBD


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

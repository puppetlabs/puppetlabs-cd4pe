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

_UX_: The yellow text on the web ui pages evokes link text.  At small sizes, it is also harder to read.  Suggest using bold for emphasis instead.


### Configure endpoint

_Setup_:
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/configure`
* Download [test license](https://github.com/puppetlabs/pipelines-self-paced/blob/master/cd4pe/assets/license.json)


Note: [CDPE-1639](https://tickets.puppetlabs.com/browse/CDPE-1639)
  * Test input
  * Test reload scenarios
     * FAILED: When license has already been uploaded, the configure endpoint
       still prompts for license.
     * FAILED: Uploading duplicate license cannot be completed. Replies with the
       following error when trying to accept the License Aggreement.
```
You do not have access to this operation. Please contact an administrator to gain access.
```

This endpoint provides several forms for configuration:
  * Endpoints
  * Storage
  * License

|  Test Name |  Steps |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify license - should provide understandable error (invalid json) | 1. Create empty text file on local machine <BR> 2. Navigate to `http://<cd4pe-instance.:<web-ui-port>/configure`  <BR> 3. Click 'License' 4. Click Choose button 5. Select file 6. Click Submit License button | License application should fail, reporting that license file is invalid  | |
| Verify license - should provide understandable error (invalid license schema) | 1. Create json file on local machine with contents of '{}' <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/configure`  <BR> 3. Click 'License' 4. Click Choose button 5. Select file 6. Click Submit License button | License application should fail, reporting that license file is invalid  | |
| Verify license - should provide understandable error (invalid license) | 1. Create json file on local machine with contents of '{ "document": { "address": "", "companyName": "", "contactEmail": "", "contactName": "", "created": "", "eula": "", "expiration": "", "id": "", "nodes": "", "projects": "", "servers": "", "type": "" }, "signature": "", "eula": "" }' <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/configure`  <BR> 3. Click 'License' 4. Click Choose button 5. Select file 6. Click Submit License button | License application should fail, reporting that license is invalid  | |
| Verify login - should reject invalid credentials (root) | 1. Submit valid license file 2. Click 'or continue to manage configurations as root' 3. Enter 'foo' in Email field 4. Enter 'bar' in Password field 5. Click  Sign In button | Login should fail, reporting that credentials are unknown | |
| Verify login - should accept valid credentials (root) | 1. Submit valid license file 2. Click 'or continue to manage configurations as root' 3. Enter email used during installation in Email field 4. Enter password used during installation in Password field 5. Click  Sign In button | Login should succeed | _UX:_ The usage of "root" is not used during installation via integrations.  During installation, this is refered to as the "Continuous Delivery for PE administrator" account.  These terms should be consistent. |


### Create initial user
_Setup_: Navigate to `http://<cd4pe-instance>:<web-ui-port>/signup`

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
Tested as per initial user

_UX_: If the user has proceeded with the "root" account and logged in, there is not an obvious path for creating a user account.  This can be accomplished by logging out and clicking the "Create an account" link on the sign in screen, but this is not intuitive while following the documentation.

_UX_: What is the expected session length?  Currently, user sessions do not seem to expire.  Is this considered a security issue?


## Source Control Integration


### Azure
TBD


### Bitbucket
[Doc](https://puppet.com/docs/continuous-delivery/2.x/integrations.html#integrate-bitbucket-server)

_Setup_:
* Create Bitbucket server (instructions out of scope).
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/settings`
* Click Source Control link
* Click on Bitbucket Server link: Bitbucket Server Credentials modal should open

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify Bitbucket Server Host field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should fail, reporting that the field must be populated | |
| Verify Bitbucket Server Host field - maximum (domain 255) | 1. Fill field with a host value whose domain exceeds 255 characters <BR>  2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should fail, reporting that hostname is invalid (support schema) | |
| Verify Bitbucket Server Host field  - invalid | 1. Fill field with '!@#$%^&?' value <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should fail, reporting that hostname is invalid (support schema) | |
| Verify Bitbucket Server Host field  - Supports multilingual domain  | 1. Fill field with 'http://스타벅스코리아.com/' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | |
| Verify Bitbucket Server Host field  - Trims whitespace  | 1. Fill field with '    http://example.org/   ' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | |
| Verify Bitbucket Server Host field  - valid  | 1. Fill field with 'http://example.org/' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | |
| Verify Username field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should fail, reporting that the field must be populated | |
| Verify Username field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Add Credentials  button | Credential setting should fail, reporting the maximum acceptable length | |
| Verify Username field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | Does Bitbucket support this?|
| Verify Username field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify PE authentication | |
| Verify Password field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should fail, reporting that the field must be populated | |
| Verify Password field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should fail, reporting the maximum acceptable length | |
| Verify Password field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | |
| Verify Password field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | |
| Verify SSH Port field - minimum (1)  | 1. Leave field blank <BR>  2. Fill in other fields <BR>  3. Click Add Crentials button | Credential setting should fail, reporting that the field must be populated | |
| Verify SSH Port field - not zero  | 1. Fill field with '0' <BR>  2. Fill in other fields <BR>  3. Click Add Crentials button | Credential setting should fail, reporting that the field must be a value between 1-65535 | |
| Verify SSH Port field - maximum (65535)  | 1. Fill field with '65536' <BR>  2. Fill in other fields <BR>  3. Click Add Crentials button | Credential setting should fail, reporting that the field must be a value between 1-65535 | |
| Verify SSH Port field - non-numeric  | 1. Fill field with 'a' <BR>  2. Fill in other fields <BR>  3. Click Add Crentials button | Credential setting should fail, reporting that the field must be a value between 1-65535 | |
| Verify SSH Url field - minimum (0) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | |
| Verify SSH Url field - maximum (domain 255) | 1. Fill field with a host value whose domain exceeds 255 characters <BR>  2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should fail, reporting that hostname is invalid (support schema) | |
| Verify SSH Url field  - invalid | 1. Fill field with '!@#$%^&?' value <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should fail, reporting that hostname is invalid (support schema) | |
| Verify SSH Url field  - Supports multilingual domain  | 1. Fill field with 'http://스타벅스코리아.com/' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | |
| Verify SSH Url field  - Trims whitespace  | 1. Fill field with '    http://example.org/   ' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | |
| Verify SSH Url field  - valid  | 1. Fill field with 'http://example.org/' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | |
| Verify SSH User field - minimum (0) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | |
| Verify SSH User field - maximum (?) | 1. Fill field with string exceeding maximum  <BR>  2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should fail, reporting the maximim allowable value | |
| Verify SSH User field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify Bitbucket authentication | Does Bitbucket support this? |
| Verify SSH User field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Add Credentials button | Credential setting should proceed to verify PE authentication | |


### GitHub
_Setup_:
* [Create GitHub OAuth](https://developer.github.com/apps/building-oauth-apps/creating-an-oauth-app/)
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/root/settings`
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


### GitLab <a id="vcs-gitlab"></a>
_Setup_:
* Create GitLab server
  * Provision host
  * Install software
      ```
      curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
      EXTERNAL_URL="http://$(hostname)" yum install -y gitlab-ee
      ```
  * Set root password by opening `$EXTERNAL_URL` in a browser
  * Create access token in `$EXTERNAL_URL/profile/personal_access_tokens`

No specific integration required.  Nothing to test.


## PE Integration
_Setup_: Create "Continuous Delivery" user as per [docs](https://puppet.com/docs/continuous-delivery/2.x/integrate_with_puppet_enterprise.html#task-1594).

_UX_: For PE integrations, this should be performed by the install process.

_Setup_: Add PE credentials to CD4PE as per [docs](https://puppet.com/docs/continuous-delivery/2.x/integrate_with_puppet_enterprise.html#task-7458).

_Setup_: Enable code manager in PE as per [docs](https://puppet.com/docs/pe/2019.1/code_mgr_config.html#code-mgr-enable)

_DOCS_: Notify the user on this page that code manager must be enabled and link to instructions

_Docs_: It should be pointed out in the [docs](https://puppet.com/docs/continuous-delivery/2.x/integrate_with_puppet_enterprise.html#task-7458) that this step cannot be performed by the CD4PE "root" user.

_Setup_:
* Login to CD4PE as a non-root user
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/settings/puppet-enterprise`
* Click Add Credentials button

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify required fields - must be filled in | 1. Leave all fields blank <BR> 2. Click Save Changes button | Credential setting should fail, reporting that the required fields have not been populated | |
| Verify Name field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify Name field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting the maximum acceptable length | |
| Verify Name field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Name field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify PE console address field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify PE console address field - invalid url  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that value is an invalid url | _UX_: Recommend help link. _UX_: Strip out echo of "java.net.UnknownHostException" from error notice |
| Verify PE console address field - Supports multilingual domain  | 1. Fill field with 'http://스타벅스코리아.com/' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should resolve the domain (116.126.86.86) but fail to authenticate | |
| Verify PE console address field - should protect against semantic url attacks   | 1. Fill field with 'https://my.pe.server.org/evil/endpoint?resetpassord=true&user=admin' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that value is an invalid url | |
| Verify PE console address field - valid  | 1. Fill field with 'https://<pe-console-server>' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Username field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify Username field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting the maximum acceptable length | |
| Verify Username field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Username field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Password field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify Password field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting the maximum acceptable length | |
| Verify Password field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Password field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Token Lifetime (months/years) fields - exclusive (months) | 1. Fill years field with '1' <BR> 2. Fill in months field with '1' | Months field should override years field| |
| Verify Token Lifetime (months/years) fields - exclusive (years) | 1. Fill months field with '1' <BR> 2. Fill in years field with '1' | Years field should override months field| |
| Verify Token Lifetime (months) field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields except for Token Lifetime (Years) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify Token Lifetime (months) field - non-zero | 1. Fill field with '0' <BR> 2. Fill in other fields except for Token Lifetime (Years) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | |
| Verify Token Lifetime (months) field - positive | 1. Fill field with '-1' <BR> 2. Fill in other fields except for Token Lifetime (Years) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | |
| Verify Token Lifetime (months) field - number | 1. Fill field with 'hello' <BR> 2. Fill in other fields except for Token Lifetime (Years) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | |
| Verify Token Lifetime (months) field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields except for Token Lifetime (Years)<BR> 3. Click Save Changes button | Credential setting should fail, reporting the maximum acceptable length | |
| Verify Token Lifetime (months) field - Valid  | 1. Fill field with '1' <BR> 2. Fill in other fields except for Token Lifetime (Years)<BR> 3. Click Save Changes button |  Credential setting should proceed to verify PE authentication | |
| Verify Token Lifetime (years) field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields except for Token Lifetime (Months) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify Token Lifetime (years) field - non-zero | 1. Fill field with '0' <BR> 2. Fill in other fields except for Token Lifetime (Months) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | |
| Verify Token Lifetime (years) field - positive | 1. Fill field with '-1' <BR> 2. Fill in other fields except for Token Lifetime (Months) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | |
| Verify Token Lifetime (years) field - number | 1. Fill field with 'hello' <BR> 2. Fill in other fields except for Token Lifetime (Months) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | |
| Verify Token Lifetime (years) field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields except for Token Lifetime (Months)<BR> 3. Click Save Changes button | Credential setting should fail, reporting the maximum acceptable length | |
| Verify Token Lifetime (years) field - Valid  | 1. Fill field with '1' <BR> 2. Fill in other fields except for Token Lifetime (Months)<BR> 3. Click Save Changes button |  Credential setting should proceed to verify PE authentication | |
| Verify API Token field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify API Token field - maximum (45)  | 1. Fill field with string exceeding 45 characters <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting an invalid token was entered | |
| Verify API Token field - invalid character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting an invalid token was entered | |
| Verify API Token field - valid  | 1. Fill field with '0DN133wZZvN4ZEqLgYW8Gzmk4u1l5vmswlwgqpdBY1Ls' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify integration - valid  | 1. Fill all fields with legit PE credentials  <BR> 2. Click Save Changes button | Credential setting should succeed PE authentication | |


## Control Repo Setup
[Docs](https://puppet.com/docs/continuous-delivery/2.x/setting_up.html#task-3948)

_DOCS_: Link to [control repo docs](https://puppet.com/docs/pe/2019.1/control_repo.html) in this task.

_DOCS_: Other control repo documentation instructs the user to use `production`
as the default branch rather than `master`.  Further explanation here (or a link to further explanation)
about the CD4PE branching and how `production` fits in should be included here.


### Azure
TBD


### Bitbucket
TBD


### GitHub

_Setup_:
* Create GitHub control repo
* Enable source control integration for appropriate GitHub
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories`
* Click Add Control Repo button

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify OAuth redirect | 1. Select 'GitHub' from list <BR> 2. Click Add Credentials button | Browser should be redirected to GitHub OAuth Application authorization page: <BR> * _Organizations and teams_ should set to 'Read-only access' <BR> _Repositories_ should be set to 'Public and private' <BR> _Personal User Data_ should be set to 'Email addresses (read-only)' | |
| Verify organization redirect | 1. Successfully perform 'Verify OAuth redirect' test <BR> 2. Click 'Authorize' button <BR> 3. Submit GitHub password if instructed | Browser should be redirected to cd4pe 'Add Control Repo' dialog with a 'Select Organization' prompt containing the user and organizations associated with the GitHub OAuth application | |
| Verify organization selection | 1. Successfully perform 'Verify organization redirect' test <BR> 2. Select username in 'Select organization' list | 'Select repository' selection should appear | |
| Verify repository selection | 1. Successfully perform 'Verify organization selection' test <BR> 2. Select control repo in 'Select repository' list | 'Create master branch from' selection should appear | _UX_: Should the repos in the list be sorted alphabetically? |
| Verify create master branch from selection | 1. Successfully perform 'Verify repository selection' test <BR> 2. Select the main branch in 'Select branch' list  | 1. 'Control repo name' field should appear and be pre-populated with the control repo name <BR> 2. 'Add' button should appear | |
| Verify add control repo | 1. Successfully perform 'Verify create master branch from selection' test <BR> 2. Click Add button | Control repo object should be created in CD4PE and browser should be redirected to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories/<repo-name>`| |
| Verify delete control repo | 1. Successfully perform 'Verify add control repo' test <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories` 3. Click trash-can icon for control repo | Deletion confirmation modal should appear
| Verify delete control repo button | 1. Successfully perform 'Verify delete control repo' test <BR> 2. Click Delete button | Control repo should be absent from list | |
| Verify no control repos | 1. Delete all control repos | 1. Control repo list should be empty <BR> 2. 'Add control repository' step in setup checklist should be unchecked | |


### GitHub Enterprise
TBD


### GitLab
_Setup_:
* Create [GitLab server](#vcs-gitlab)
* Create GitLab control repo
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories`
* Click Add Control Repo button

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify source control selection | 1. Select 'GitLab' from list | 'Select organization' selection should appear | |
| Verify organization selection | 1. Successfully perform 'Verify source control selection' test <BR>  2. Select username in 'Select organization' list | 'Select repository' selection should appear | _UX_: This selection is for a Gitlab user not an organization |
| Verify repository selection | 1. Successfully perform 'Verify organization selection' test <BR>  2. Select control repo in 'Select repository' list | 'Create master branch from' selection should appear | _UX_: Should the repos in the list be sorted alphabetically? |
| Verify create master branch from selection | 1. Successfully perform 'Verify repository selection' test <BR> 2. Select the main branch in 'Select branch' list  | 1. 'Control repo name' field should appear and be pre-populated with the control repo name <BR> 2. 'Add' button should appear | |
| Verify add control repo | 1. Successfully perform 'Verify create master branch from selection' test <BR> 2. Click Add button | Control repo object should be created in CD4PE and browser should be redirected to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories/<repo-name>`| |
| Verify delete control repo | 1. Successfully perform 'Verify add control repo' test <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories` 3. Click trash-can icon for control repo | Deletion confirmation modal should appear
| Verify delete control repo button | 1. Successfully perform 'Verify delete control repo' test <BR> 2. Click Delete button | Control repo should be absent from list | |
| Verify no control repos | 1. Delete all control repos | 1. Control repo list should be empty <BR> 2. 'Add control repository' step in setup checklist should be unchecked | |


## Add Job Hardware
[Docs](https://puppet.com/docs/continuous-delivery/2.x/configure_job_hardware.html)

_DOCS_: Order of configuration docs
* Required v optional: job hardware v impact analysis
* Order to reduce impact (e.g. Configure SSL requires reinstall of distelli agent, so it should come before job hardware doc)
* Order docs to match setup ux:
  * Integrate Puppet Enterprise
  * Integrate source control
  * Set up job hardware
  * Add control repository
  * Create a pipeline

_Setup_:
* Provision linux host
* Provision windows host
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/job-hardware`

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify Add Job Hardware button (\*nix) | 1. Click Job Hardware button | Modal should appear with shell commands listed for \*nix by default | _UX_: Provide guidance about credentials that should be entered when running `distelli agent install` |
| Verify Add Job Hardware button (windows) | 1. Successfully perform 'Verify Add Job Hardware button (\*nix)' test <BR>  2. Click 'Windows' link | Shell commands listed for windows should appear | _UX_: Instruction for 'SSH' should be 'Remote Desktop' _UX_: Link text is no different than regular text. |
| Verify distelli install (\*nix) | 1. Successfully perform 'Verify Add Job Hardware button (\*nix)' test <BR>  2. SSH to linux host as root <BR>  3. Run first command displayed in CD4PE | Command should successfully complete;  STDOUT should include `To install the agent, run` | |
| Verify distelli agent install (\*nix) | 1. Successfully perform 'Verify distelli install (\*nix)' test <BR>  2. SSH to linux host as root <BR>  3. Run second command displayed in CD4PE | Command should successfully complete;  STDOUT should include `Starting Distelli supervisor` | |
| Verify distelli agent install (\*nix distelli.yml)  | 1. Successfully perform 'Verify distelli install (\*nix)' test <BR>  2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/settings/agent` <BR>  3. Click 'Create Credential' link <BR>  4. SSH to linux host as root <BR> 5. Create a `distelli.yml` file on the host containing `---\nDistelliAccessToken: <MY_ACCESS_TOKEN>\nDistelliSecretKey: <MY_SECRET_KEY>` where the token and key are copied from the generated credential in step 3 <BR> 6. Run second command displayed in CD4PE, appending `-conf <PATH_TO_DISTELLI.YML_FILE>` to the command | Command should successfully complete;  STDOUT should include `To install the agent, run` | |
| Verify distelli install (windows) | 1. Successfully perform 'Verify Add Job Hardware button (windows)' test <BR>  2. Remote Desktop to windows host as Administrator <BR>  3. Run first command displayed in CD4PE in a command window | Command should successfully complete; STDOUT should include `To install the agent, run` | |
| Verify distelli agent install (windows) | 1. Successfully perform 'Verify distelli install (windows)' test <BR>  2. Remote Desktop to windows host as Administrator <BR>  3. Run second command displayed in CD4PE in a command window | Command should successfully complete; | _UX_: No indication in output that the command did the needful. |
| Verify distelli agent install (windows distelli.yml)  | 1. Successfully perform 'Verify distelli install (windows)' test <BR>  2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/settings/agent` <BR>  3. Click 'Create Credential' link <BR>  4. Remote Desktop to windows host as Administrator <BR> 5. Create a `distelli.yml` file on the host containing `---\r\nDistelliAccessToken: <MY_ACCESS_TOKEN>\r\nDistelliSecretKey: <MY_SECRET_KEY>` where the token and key are copied from the generated credential in step 3 <BR> 6. Run second command displayed in CD4PE, appending `-conf <PATH_TO_DISTELLI.YML_FILE>` to the command | Command should successfully complete; | _UX_: No indication in output that the command did the needful. |
| Verify Active toggle | 1. Successfully perform 'Verify distelli agent install (\*nix)' test <BR>  2. Reload `http://<cd4pe-instance>:<web-ui-port>/<username>/job-hardware` <BR>  3. Click 'Job Hardware Active' | Toggle should turn green | |
| Verify Capability field - minimum (1)  | 1. Successfully perform 'Verify distelli agent install (\*nix)' <BR>  2. Reload `http://<cd4pe-instance>:<web-ui-port>/<username>/job-hardware` <BR> 3. Click 'Add Capability' link for hardware <BR>  4. Leave field blank  5. Click Save link | Capability form should remain open | |
| Verify Capability field - maximum (?)  | 1. Successfully perform 'Verify distelli agent install (\*nix)' <BR>  2. Reload `http://<cd4pe-instance>:<web-ui-port>/<username>/job-hardware` <BR> 3. Click 'Add Capability' link for hardware <BR>  4. Fill field with string exceeding maximum  5. Click Save link | Save should fail,  reporting the maximum acceptable length  | |
| Verify Capability field - utf-8  | 1. Successfully perform 'Verify distelli agent install (\*nix)' <BR>  2. Reload `http://<cd4pe-instance>:<web-ui-port>/<username>/job-hardware` <BR> 3. Click 'Add Capability' link for hardware <BR>  4. Fill field with '©®@a.b'  5. Click Save link | Save should succeed | |
| Verify Capability field - db-inject  | 1. Successfully perform 'Verify distelli agent install (\*nix)' <BR>  2. Reload `http://<cd4pe-instance>:<web-ui-port>/<username>/job-hardware` <BR> 3. Click 'Add Capability' link for hardware <BR>  4. Fill field with "evil'ex"  5. Click Save link | Save should succeed  | _UX_: Should the '+Add Capability' link be hidden while the form is open since the form cannot opened multiple times? |



## Pipelines
[Docs](https://puppet.com/docs/continuous-delivery/2.x/start_building_your_modules_pipeline.html)

_Setup_:
* [Setup control repo](#control-repo-setup)
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories/<repo-name>`

### Create Pipeline
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify Add Pipeline link | 1. Click '+Add Pipeline' link | Modal should appear with 'Single Branch' selected by default and 'Select Branch' selection | |
| Verify pipeline single branch | 1. Successfully perform 'Verify Add Pipeline link' test <BR>  2. Click 'Single Branch' radio button | 'Select Branch' selection should appear | |
| Verify pipeline single branch - unselected | 1. Successfully perform 'Verify Add Pipeline link' test <BR>  2. Click Add Pipeline button | Error should be displayed that a branch must be selected | |
| Verify pipeline single branch - selected | 1. Successfully perform 'Verify Add Pipeline link' test <BR>  2. Select a branch from the 'Select Branch' list <BR>  3. Click Add Pipeline button | The pipeline creation should succeed | |
| Verify pipeline branch regex | 1. Successfully perform 'Verify Add Pipeline link' test <BR>  2. Click 'Branch Regex' radio button | 'Configure regex' field should appear | |
| Verify pipeline branch regex - minimum (1) | 1. Successfully perform 'Verify pipeline branch regex' test <BR>  2. Delete contents of the 'Branch Regex' field <BR>  3. Click Add Pipeline button | Invalid regex error should be displayed | |
| Verify pipeline branch regex - maximum (?) | 1. Successfully perform 'Verify pipeline branch regex' test <BR>  2. Enter '.' repeated to exceed the maximum allowed value in the 'Branch Regex' field <BR>  3. Click Add Pipeline button | Error should be displayed indicating the entry exceeds the maximum | |
| Verify pipeline branch regex - invalid | 1. Successfully perform 'Verify pipeline branch regex' test <BR>  2. Enter '[' in the 'Branch Regex' field <BR>  3. Click Add Pipeline button | Invalid regex error should be displayed | |
| Verify pipeline branch regex - groups | 1. Successfully perform 'Verify pipeline branch regex' test <BR>  2. Enter '[^0-9]\*([0-9]\*)[.]([0-9]*)[.]([0-9]*)([0-9A-Za-z-]\*)' in the 'Branch Regex' field <BR>  3. Click Add Pipeline button | The pipeline creation should succeed | |
| Verify pipeline branch regex - utf-8 | 1. Successfully perform 'Verify pipeline branch regex' test <BR>  2. Enter '©®?a.b' in the 'Branch Regex' field <BR>  3. Click Add Pipeline button | The pipeline creation should succeed | |


### Create Stage
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify Add stage button | 1. Successfully perform 'Verify pipeline single branch' test <BR>  2. Click '+Add Stage' button | Modal should appear with 'Deployment' selected by default and 'Select a node group' selection | _UX_: The button is grey, implying that it is disabled. UX seems inconsistent: if a pipeline is selected, but no stage created the treatment is different from after stage is added. |
| Verify Add stage job | 1. Successfully perform 'Verify Add stage button' test <BR>  2. Click 'Job' radio button | 'Select Job' should appear | |
| Verify Add stage job - unselected | 1. Successfully perform 'Verify Add stage job' test <BR>  2. Click Add Stage button | Error should be displayed that a branch must be selected | |
| Verify Add stage job - selected | 1. Successfully perform 'Verify Add stage job' test <BR>  2. Select a job from the 'Select Job' list <BR>  3. Click Add Stage button | The stage creation should succeed and 'add another stage' modal should appear | _DOCS_: Link to explanation of canned jobs ; _UX_: 'Add item to Stage:0' title for 'add another stage' modal is unclear; _UX_: Should be able to shift-click select multiple jobs and multiple stages added at once |
| Verify Add stage deployment | 1. Successfully perform 'Verify Add stage button' test <BR>  2. Click 'Deployment' radio button | 'Select a node group' should appear | |
| Perform tests from [manual deployment modal](#manual) | | | |
| Verify Add stage impact analysis - without deployment | 1. Successfully perform 'Verify Add stage button' test <BR>  2. Click 'Impact Analysis' radio button | Error should appear that this type of stage is not available until a deployment stage has been added | _UX_: This stage option should not be presented until it is a valid choice |
| Verify Add stage impact analysis - with deployment (immediate radio selection) | 1. Successfully add deployment stage via Direct Deployment policy without clicking Done button  <BR>  2. Click 'Impact Analysis' radio button | Impact analysis modal should appear without error | |
| Verify Add stage impact analysis - with deployment (previously created) | 1. Successfully add deployment stage via Direct Deployment policy <BR>  2. Successfully perform 'Verify Add stack button' test <BR>  3. Click 'Impact Analysis' radio button | Impact analysis modal should appear without error | |
| Verify batch size field (impact analysis) - minimum (1)  | 1. Successfully perform 'Verify Add stage impact analysis - with deployment (previously created)' test  <BR>  2. Delete the contents of the 'Compile up to xx node catalogs' field <BR>  3. Click 'Add Impact Analysis' button | Add Impact Analysis button should be grayed out/unavailable OR error should be displayed indicating that batch size must be set | |
| Verify batch size field (impact analysis) - maximum (?)  | 1. Successfully perform 'Verify Add stage impact analysis - with deployment (previously created)' test  <BR>  2. Enter a number that exceeds the allowed maximum in the 'Compile up to xx node catalogs' field <BR>  3. Click 'Add Impact Analysis' button | Add Impact Analysis button should be grayed out/unavailable OR error should be displayed indicating that the number exceeds the allowed maximum | |
| Verify batch size field (impact analysis) - not zero  | 1. Successfully perform 'Verify Add stage impact analysis - with deployment (previously created)' test  <BR>  2. Enter '0' in the 'Compile up to xx node catalogs' field <BR>  3. Click 'Add Impact Analysis' button | Add Impact Analysis button should be grayed out/unavailable OR error should be displayed indicating that the batch size must be set | |
| Verify batch size field (impact analysis) - not negative  | 1. Successfully perform 'Verify Add stage impact analysis - with deployment (previously created)' test  <BR>  2. Enter '-1' in the 'Compile up to xx node catalogs' field <BR>  3. Click 'Add Impact Analysis' button | Add Impact Analysis button should be grayed out/unavailable OR error should be displayed indicating that the batch size must be set | |
| Verify batch size field (impact analysis) - numeric  | 1. Successfully perform 'Verify Add stage impact analysis - with deployment (previously created)' test  <BR>  2. Enter 'hello' in the 'Compile up to xx node catalogs' field <BR>  3. Click 'Add Impact Analysis' button | Add Impact Analysis button should be grayed out/unavailable OR error should be displayed indicating that the batch size must be set | _UX_: The error states of this field are inconsistent with those in pipeline creation |
| Verify run for selected environments (impact analysis)  | 1. Successfully perform 'Verify Add stage impact analysis - with deployment (previously created)' test  <BR>  2. Click 'Run for selected environments' radio button | List of deployment environments should appear |
| Verify run for selected environments (impact analysis) - none selected  | 1. Successfully perform 'Verify run for selected environments (impact analysis)' test  <BR>  2. Deselect all environments <BR> 3. Click 'Add Impact Analysis' button | Error should be displayed that an environment must be selected | |
| Verify run for selected environments (impact analysis) - selected  | 1. Successfully perform 'Verify run for selected environments (impact analysis)' test  <BR>  2. Select one environment <BR> 3. Click 'Add Impact Analysis' button | Impact analysis should be created


_UX_: The following condition should be addressed by hiding the deployment options that will create the loop.
> Error for stage at index 1.
> Destinations with rolling deployment has deployment loop.
> Sorry, deploying to the testing branch from this pipeline is not allowed.
> Doing so would create an infinite deployment loop.


## Job

### Create Job
[Docs](https://puppet.com/docs/continuous-delivery/2.x/example_jobs.html#puppet-linter)??

_SETUP_:
* Navigate to Jobs


|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify New Job button | 1. Click New Job button | New Job modal should appear | |
| Verify required fields - must be filled in | 1. Leave all fields blank <BR> 2. Click Create Job button | Job creation should fail, reporting that the required fields have not been populated | |
| Verify Job Name field - minimum (1) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Leave field blank <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should fail, reporting that the field must be populated | |
| Verify Job Name field - maximum (?) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill field with string exceeding maximum <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should fail, reporting the maximum acceptable length | |
| Verify Job Name field - character set (utf-8) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill field with '©®' <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Job Name field - valid | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill field with 'a' <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Job Description field - minimum (1) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Leave field blank <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should fail, reporting that the field must be populated | |
| Verify Job Description field - maximum (?) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill field with string exceeding maximum <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should fail, reporting the maximum acceptable length | |
| Verify Job Description field - character set (utf-8) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill field with '©®' <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Job Description field - valid | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill field with 'a' <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Job Commands field - minimum (1) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Leave field blank <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should fail, reporting that the field must be populated | |
| Verify Job Commands field - maximum (?) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill field with string exceeding maximum <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should fail, reporting the maximum acceptable length | |
| Verify Job Commands field - character set (utf-8) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill field with '©®' <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Job Commands field - valid | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill field with 'a' <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Docker Image Name - minimum (1) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Leave Docker Image field blank <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that the Docker Image field must be populated when running the job in a container | |
| Verify Docker Image Name - maximum (255) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Image field with string exceeding maximum <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that the Docker Image field must be populated when running the job in a container | [Ref](https://success.docker.com/article/dtr-max-length-repo-name) |
| Verify Docker Image Name - invalid characters | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Image field with 'A☃\\?'  <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that name must conform to specification |[Ref](https://docs.docker.com/registry/spec/api/#overview) |
| Verify Docker Image Name - valid | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Image field with 'a'  <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Docker Run Arguments - minimum (0) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Leave Docker Run Arguments field blank <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Docker Run Arguments - maximum (?) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Run Arguments field with string exceeding maximum <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that the Docker Image field must be populated when running the job in a container | |
| Verify Docker Run Arguments - invalid syntax | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Image field with 'foobar'  <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that name must conform to --key=value specification |[Ref](https://docs.docker.com/engine/reference/run) |
| Verify Docker Run Arguments - invalid character set | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Image field with '--☃=y'  <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that name must conform to ascii specification |[Ref](https://docs.docker.com/engine/reference/run) |
| Verify Docker Image Name - valid syntax | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Image field with '--x="no-new-privileges:true\|false"'  <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Capabilities selection - minimum (1) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Leave Capabilities selection items unselected  <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should fail, reporting that a capability must be selected | |
| Verify Capabilities selection - maximum (3) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Select 4 items in Capabilities selection  <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should fail, reporting the maximum | |
| Verify Environment Variables - minimum (0) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Leave Environment Variables field blank <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Environment Variables - maximum (?) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill Environment Variables field with string exceeding maximum <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should fail, reporting the maximum acceptable length | |
| Verify Environment Variables - invalid syntax | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill Environment Variables field with 'foobar'  <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should fail, reporting that name must conform to key=value specification | |
| Verify Environment Variables - valid syntax | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill Environment Variables field with 'foo=bar\nbar=baz'  <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should succeed and job should be available in the jobs list |
| Verify Environment Variables - character set (utf-8) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Fill Environment Variables field with 'foo=©®'  <BR>  3. Fill in other fields <BR>  4. Click Create Job button | Job creation should succeed and job should be available in the jobs list |


## Code Deploy
[Docs](https://puppet.com/docs/continuous-delivery/2.x/start_deploying.html)

_Setup_:
* [Integrate with PE](#pe-integration)
* [Create environemt node groups](https://puppet.com/docs/continuous-delivery/2.x/start_deploying.html#task-8401) for testing environment. Is part of this performed by the integration job in 2019.1.0?
* [Create job hardware](#add-job-hardware)
* Create node for testing environment
  * Provision
  * Install PE agent `curl -k https://<pe-server>:8140/packages/current/install.bash | bash`
  * Regenerate cert with `pp_environment` trusted fact.
    * Stop agent: `puppet apply -e 'service { "puppet": ensure => "stopped" }'`
    * Nuke cert: `rm -rf /etc/puppetlabs/puppet/ssl/*`
    * Create csr extension attribute:
        ```
        cat > $(puppet config print confdir)/csr_attributes.yaml <<EOF
        ---
        extension_requests:
          pp_environment: 'testing'
        EOF
        ```
    * On the master, revoke and clean the previous agent cert: `AGENT_CERT=<agent certname> ; puppetserver ca revoke --certname $AGENT_CERT && puppetserver ca clean --certname $AGENT_CERT`
      * _UX_: I expected the "Reject" button in PE to do this.
    * On the agent, submit new cert request: `puppet agent -t`
    * On the master, sign cert request
    * On the agent, apply catalog: `puppet agent -t`

_DOCS_: https://puppet.com/docs/continuous-delivery/2.x/start_deploying.html#concept-9880 s/An environment node group is node group/An environment node group is a node group/

_DOCS_: "pp_environment trusted fact": Link to documentation on how to apply the trusted fact to nodes

_DOCS_: "Specify the Git branch corresponding to the environment.":  How??  This seems to happen _magically_ without user intervention.

### Manual
[Docs](https://puppet.com/docs/continuous-delivery/2.x/start_deploying.html#task-3794)

_Setup_:
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories`
* Click on appropriate control repo

_DOCS_: s/Select he branch/Select the branch/

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify New Deployment button | 1. Click New Deployment button | Modal should appear with all branches listed | _UX_: Without docs, this button is difficult to discover |
| Verify branch selection | 1. Successfully perform 'Verify New Deployment button' test <BR> 2. Select 'testing' in 'Select a branch' list | 'Select a commit' selection should appear | _UX_: Selection name is not consistent with Job Hardware modal |
| Verify commit selection | 1. Successfully perform 'Verify branch selection' test <BR> 2. Select commit in 'Select a commit' list | 'Select Puppet Enterprise instance' selection should appear with a default selection <BR> 'Select a node group' selection should appear |  _UX_: Selection names are not internally consistent |
| Verify node group selection | 1. Successfully perform 'Verify commit selection' test <BR> 2. Select 'All testing' node group in 'Select a node group' list | 'Select a deployment policy' selection should appear | _UX_: Blue text within selection boxes implies a link but does not have that functionality.  Suggest a different color for emphasis. |
| Verify deployment policy help | 1. Successfully perform 'Verify node group selection' test <BR> 2. Click 'Help me choose' link in 'Select a deployment policy' header | Deployment Policy document should be opened in another browser tab | |
| Verify Direct Deployment policy selection | 1. Successfully perform 'Verify node group selection' test <BR> 2. Select  'Direct Deployment Policy' in 'Select a deployment policy' list | Policy settings should appear <BR>  All settings _except_ timeout should be disabled <BR> Description field should appear | |
| Verify Timeout field (direct deployment) - minimum (1)  | 1. Successfully perform 'Verify Direct Deployment policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Timeout field (direct deployment) - maximum (1440)  | 1. Successfully perform 'Verify Direct Deployment policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter '2000' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Timeout field (direct deployment) - numeric | 1. Successfully perform 'Verify Direct Deployment policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate Conditions toggle (direct deployment) | 1. Successfully perform 'Verify Direct Deployment policy selection' test <BR>  2. Click the 'Abort deployment if' box | Toggle should turn green and node count field should be enabled  | |
| Verify Terminate nodes field (direct deployment) - minimum (1)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate nodes field (direct deployment) - maximum (?)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeds the allowed maximum in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate nodes field (direct deployment) - numeric | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify No-op toggle (direct deployment) | 1. Successfully perform 'Verify Direct Deployment policy selection' test <BR>  2. Click the 'Run this deployment in no-op mode' box | Toggle should turn green | |
| Verify direct deployment | 1. Successfully perform 'Verify Direct Deployment policy selection' test  <BR>  3. Enter 'test deploy' in the Description field  4. Click 'Deploy' button | Deploy should be successfully submitted | |
| Verify Eventual Consistency policy selection | 1. Successfully perform 'Verify node group selection' test <BR>  2. Select 'Eventual Consistency Policy' in 'Select a deployment policy' list | Description field should appear | |
| Verify eventual consistency deployment | 1. Successfully perform 'Verify Eventual Consistency policy selection' test  <BR>  3. Enter 'test deploy' in the Description field  4. Click 'Deploy' button | Deploy should be successfully submitted | |
| Verify Temporary Branch policy selection | 1. Successfully perform 'Verify node group selection' test <BR> 2. Select  'Temporary Branch Policy' in 'Select a deployment policy' list | Policy settings should appear <BR>  All settings _except_ timeout and stagger should be disabled <BR> Description field should appear | |
| Verify Timeout field (temp branch) - minimum (1)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Timeout field (temp branch) - maximum (1440)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter '2000' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Timeout field (temp branch) - numeric | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (temp branch) - minimum (1)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (temp branch) - maximum (?)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (temp branch) - numeric | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (temp branch) - minimum (1)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (temp branch) - maximum (?)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (temp branch) - numeric | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate Conditions toggle (temp branch) | 1. Successfully perform 'Verify Temporary Branch policy selection' test <BR>  2. Click the 'Abort deployment if' box | Toggle should turn green and node count field should be enabled  | |
| Verify Terminate nodes field (temp branch) - minimum (1)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate nodes field (temp branch) - maximum (?)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeds the allowed maximum in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate nodes field (temp branch) - numeric | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify No-op toggle (temp branch) | 1. Successfully perform 'Verify Temporary Branch policy selection' test <BR>  2. Click the 'Run this deployment in no-op mode' box | Toggle should turn green | |
| Verify temporary branch deployment | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field  4. Click 'Deploy' button | Deploy should be successfully submitted | |
| Verify Incremental Branch policy selection | 1. Successfully perform 'Verify node group selection' test <BR> 2. Select  'Incremental Branch Policy' in 'Select a deployment policy' list | Policy settings should appear <BR>  All settings _except_ timeout and stagger should be disabled <BR> Description field should appear | |
| Verify Timeout field (incr branch) - minimum (1)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Timeout field (incr branch) - maximum (1440)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter '2000' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Timeout field (incr branch) - numeric | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (incr branch) - minimum (1)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (incr branch) - maximum (?)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (incr branch) - numeric | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (incr branch) - minimum (1)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (incr branch) - maximum (?)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (incr branch) - numeric | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate Conditions toggle (incr branch) | 1. Successfully perform 'Verify Incremental Branch policy selection' test <BR>  2. Click the 'Abort deployment if' box | Toggle should turn green and node count field should be enabled  | |
| Verify Terminate nodes field (incr branch) - minimum (1)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate nodes field (incr branch) - maximum (?)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeds the allowed maximum in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate nodes field (incr branch) - numeric | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify No-op toggle (incr branch) | 1. Successfully perform 'Verify Incremental Branch policy selection' test <BR>  2. Click the 'Run this deployment in no-op mode' box | Toggle should turn green | |
| Verify incremental branch deployment | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field  4. Click 'Deploy' button | Deploy should be successfully submitted | |
| Verify Blue Green Branch policy selection | 1. Successfully perform 'Verify node group selection' test <BR> 2. Select  'Blue Green Branch Policy' in 'Select a deployment policy' list | Policy settings should appear <BR>  All settings _except_ timeout and stagger should be disabled <BR> Description field should appear | |
| Verify Timeout field (blue/green branch) - minimum (1)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Timeout field (blue/green branch) - maximum (1440)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter '2000' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Timeout field (blue/green branch) - numeric | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (blue/green branch) - minimum (1)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (blue/green branch) - maximum (?)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (blue/green branch) - numeric | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (blue/green branch) - minimum (1)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (blue/green branch) - maximum (?)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (blue/green branch) - numeric | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate Conditions toggle (blue/green branch) | 1. Successfully perform 'Verify Blue Green Branch policy selection' test <BR>  2. Click the 'Abort deployment if' box | Toggle should turn green and node count field should be enabled  | |
| Verify Terminate nodes field (blue/green branch) - minimum (1)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate nodes field (blue/green branch) - maximum (?)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeds the allowed maximum in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate nodes field (blue/green branch) - numeric | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify No-op toggle (blue/green branch) | 1. Successfully perform 'Verify Blue Green Branch policy selection' test <BR>  2. Click the 'Run this deployment in no-op mode' box | Toggle should turn green | |
| Verify blue green branch deployment | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field  4. Click 'Deploy' button | Deploy should be successfully submitted | |


### Pipeline
[Docs](https://puppet.com/docs/continuous-delivery/2.x/start_building_your_modules_pipeline.html#task-8025)

_Setup_:
* Perform [add job hardware](#add_job_hardware) setup.
* Perform [code deploy](#code-deploy) setup.


#### Job <a name="pipeline-job"></a>
[Doc](https://puppet.com/docs/continuous-delivery/2.x/example_jobs.html)

_Setup_:
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories`
* Click on appropriate control repo
* Click on master branch


##### Control Repo Puppetfile Syntax Validate
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify puppetfile-syntax-validate job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'control-repo-puppetfile-syntax-validate' should be present in the 'Select Job' list | |
| Verify Add puppetfile-syntax-validate job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'control-repo-puppetfile-syntax-validate' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'control-repo-puppetfile-syntax-validate' job should appear as Pipeline stage | |
| Verify puppetfile-syntax-validate job trigger - success | 1. Add and commit a change to the control repo master branch adding a comment to the Puppetfile <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify puppetfile-syntax-validate job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates the Puppetfile <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify puppetfile-syntax-validate job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify puppetfile-syntax-validate job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<username>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Validate that a control repo's Puppetfile is syntactically correct/ | |


##### Control Repo Template Syntax Validate
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify template-syntax-validate job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'control-repo-template-syntax-validate' should be present in the 'Select Job' list | |
| Verify Add template-syntax-validate job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'control-repo-template-syntax-validate' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'control-repo-template-syntax-validate' job should appear as Pipeline stage | |
| Verify template-syntax-validate job trigger - success | 1. Add and commit a change to the control repo master branch adding a comment to a template <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify template-syntax-validate job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates a template <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify template-syntax-validate job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify template-syntax-validate job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<username>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Validate that a control repo's templates are syntactically correct/ | |


##### Control Repo Hiera Syntax Validate
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify hiera-syntax-validate job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'control-repo-hiera-syntax-validate' should be present in the 'Select Job' list | |
| Verify Add hiera-syntax-validate job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'control-repo-hiera-syntax-validate' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'control-repo-hiera-syntax-validate' job should appear as Pipeline stage | |
| Verify hiera-syntax-validate job trigger - success | 1. Add and commit a change to the control repo master branch adding a comment to the hiera data <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify hiera-syntax-validate job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates the hiera data <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify hiera-syntax-validate job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify hiera-syntax-validate job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<username>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Validate that a control repo's Hiera data is syntactically correct/ | |


##### Control Repo Puppet Manifest Syntax Validate
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify manifest-syntax-validate job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'control-repo-manifest-syntax-validate' should be present in the 'Select Job' list | |
| Verify Add manifest-syntax-validate job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'control-repo-manifest-syntax-validate' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'control-repo-manifest-syntax-validate' job should appear as Pipeline stage | |
| Verify manifest-syntax-validate job trigger - success | 1. Add and commit a change to the control repo master branch adding a comment to a manifest <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify manifest-syntax-validate job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates a manifest <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify manifest-syntax-validate job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify manifest-syntax-validate job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<username>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Validate that a control repo's Puppet manifest code is syntactically correct/ | |


##### Module PDK Validate
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify pdk-validate job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'module-pdk-validate' should be present in the 'Select Job' list | |
| Verify Add pdk-validate job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'module-pdk-validate' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'module-pdk-validate' job should appear as Pipeline stage | |
| Verify pdk-validate job trigger - success | 1. Add and commit a change the module master branch adding a comment to a manifest <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify pdk-validate job trigger - failure | 1. Add and commit a change to the module master branch that invalidates a manifest <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify pdk-validate job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify pdk-validate job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<username>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Validate that a module's Puppet manifest code is syntactically correct/ | |


##### Run Module Unit Test
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify rspec-puppet job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'module-rspec-puppet' should be present in the 'Select Job' list | |
| Verify Add rspec-puppet job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'module-rspec-puppet' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'module-rspec-puppet' job should appear as Pipeline stage | |
| Verify rspec-puppet job trigger - success | 1. Add and commit a change to the module master branch adding a comment to an rspec test <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify rspec-puppet job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates an rspec test <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify rspec-puppet job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify rspec-puppet job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<username>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Run rspec-puppet unit tests on a module/ | |


##### Custom Job
[Docs](https://puppet.com/docs/continuous-delivery/2.x/example_jobs.html#puppet-linter)
_SETUP_:
* Navigate to Jobs
* Click 'New Job' button
* Enter 'control-repo-custom' in Job name field
* Enter 'Lint Puppet Code' in Description field
* Enter the following in Commands field
```
#!/bin/bash

LINT_OPTS=("--fail-on-warnings" "--no-documentation-check" "--no-140chars-check" "--no-autoloader_layout-check" "--no-class_inherits_from_params_class-check")

for f in **/**pp; do
   [[ $f =~ plans/ ]] && continue

   if puppet-lint "${LINT_OPTS[@]}" "$f"; then
      echo "SUCCESS: $f"
   else
      echo "FAILED: $f"
      failures+=("$f")
   fi
done

if (( ${#failures[@]} > 0 )); then
   echo "Puppet-lint validation on the Control Repo has failed in the following manifests:"
   echo -e "\t ${failures[@]}"
   exit 1
else
   echo "Puppet-lint validation on the Control Repo has succeeded."
fi
```
* Enable docker configuration
* Select DOCKER capability
* Enter 'puppet/puppet-dev-tools' in the docker container field
* Click 'Create Job' button:  Job should be successfully created
* Click 'Done' button:  Job should be visible in jobs list


|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify custom job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'control-repo-custom' should be present in the 'Select Job' list | |
| Verify Add custom job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'control-repo-custom' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'control-repo-custom' job should appear as Pipeline stage | |
| Verify custom job trigger - success | 1. Add and commit a change to the control-repo master branch adding a comment to an rspec test <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify custom job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates an rspec test <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify custom job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify custom job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<username>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Puppet-lint validation on the Control Repo has/ | |


_BUG_:?? Capability requirements for existing stages are not updated after job capabilities are updated when executing re-run.


#### Deploy
_Setup_:
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories`
* Click on appropriate control repo
* Click on master branch
* Create pipeline with deploy stage:
  1. Successfully perform 'Verify Add stage deployment' test from the [Pipelines: Create Stage](#create-stage) section above on the master pipeline.
  1. Select the 'testing' node group
  1. Select the 'Direct Deployment Policy' deployment policy
  1. Click 'Add Stage'

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify commit hook event | 1. Add and commit a change to the control repo master branch <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | The 'New Events' button should appear on the `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories/<control-repo>` page | |
| Verify deployment trigger | 1. Successfully complete 'Verify commit hook event' test <BR>  2. Click the 'New Events' button | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A deployment succeeded notice | |
| Verify deploy event pipeline detail | 1. Successfully complete 'Verify deployment trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the deployment run <BR> - A Push webhook | |
| Verify deploy details | 1. Successfully complete 'Verify deploy event pipeline detail' test <BR>  2. Click the link to the deploy number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<username>/deployments/<deploy-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the deploy. <BR> - Update Ref: A commit push to the testing branch <BR> - Code deploy: Indicating the testing environment <BR> - Rolling Deployment: A link to the PE job running puppet on the nodes classified for the testing environment <BR> - Cleanup | _UX_: If puppet run completes with failures, the color of the 'Puppet Run Jobs' should not be green. |


#### Pull Request
_Setup_:
* Perform [Code Deploy::Pipelines::Job](#pipeline-job) setup.
* Enable Pull Request trigger on pipeline
  1. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories/<control-repo>`
  1. Click 'Pipeline Settings' for master pipeline (tool icon)
  1. Enable 'Pull Request' trigger (_UX_: Label 'Pull Request' with space)
  1. Click 'Save Settings' button
  1. Click 'Done' button
* Create `foobar` branch on the control repo


|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify pull request hook event | 1. Add and commit a change to the control repo foobar branch <BR>  2. Push the change, if necessary, to the git server <BR>  3. Open a request to merge changes from foobar branch to master branch <BR>  4. Wait 5 seconds | The 'New Events' button should appear on the `http://<cd4pe-instance>:<web-ui-port>/<username>/repositories/<control-repo>` page | |
| Verify pull request trigger - success | 1. Successfully complete 'Verify pull request hook event' test <BR>  2. Click the 'New Events' button | An event for the PR should appear at the top of the event list.  It should include: <BR> - `foobar @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify pull request event pipeline detail | 1. Successfully complete 'Verify pull request trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Pull Request webhook | |
| Verify pull request job details | 1. Successfully complete 'Verify pull request event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<username>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `foobar @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. | |
| Verify pull request VCS integration | 1. Successfully complete 'Verify pull request hook event' test <BR>  2. Open the VCS UI for the pull request opened | An entry for the pipeline should appear.  It should include: <BR> - A link to the event for the run of the pipeline stage | |


## Impact Analysis
TBD

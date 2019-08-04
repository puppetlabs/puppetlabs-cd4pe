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
| Verify host field - must be managed host | 1. Fill field with non-managed host value <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | [CDPE-1960](https://tickets.puppetlabs.com/browse/CDPE-1960) |
| Verify Administrator email field - must be filled in | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify Administrator email field - should accept email address with TLD | 1. Fill field with '!def!xyz%abc@example.org' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | https://tools.ietf.org/html/rfc3696 |
| Verify Administrator email field - should accept UTF-8 in local | 1. Fill field with email '©®@a.b' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | https://tools.ietf.org/html/rfc6531 | [CDPE-1961](https://tickets.puppetlabs.com/browse/CDPE-1961) |
| Verify Administrator email field - should reject malformed email address | 1. Fill field with "evil'ex" <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify Administrator email field - should accept local of 64 chars | 1. Fill field with 'MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlis@example.org' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | |
| Verify Administrator email field - local must not exceed 64 chars | 1. Fill field with 'MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistment@example.org' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | [Email spec ref](https://tools.ietf.org/html/rfc3696),  [CDPE-1962](https://tickets.puppetlabs.com/browse/CDPE-1962) |
| Verify Administrator email field - should accept domain of 255 chars | 1. Fill field with 'user@MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistmentVaudevilleLatishaDecriedJovianLenghtwiseTroubleshooterClamberCaterersAnthropologistGarbedSlicerExpediencyBroodingPilafRiddlesForthcomingUnkindlierTitanicAlzheimerDoubterDumpedFifesMe.org' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | [CDPE-1963](https://tickets.puppetlabs.com/browse/CDPE-1963) |
| Verify Administrator email field - domain must not exceed 255 chars | 1. Fill field with 'user@MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistmentVaudevilleLatishaDecriedJovianLenghtwiseTroubleshooterClamberCaterersAnthropologistGarbedSlicerExpediencyBroodingPilafRiddlesForthcomingUnkindlierTitanicAlzheimerDoubterDumpedFifesMel.org' <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify Administrator password field - minimum (1)  | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | |
| Verify Administrator password field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Install button | Install button should be disabled | [CDPE-1964](https://tickets.puppetlabs.com/browse/CDPE-1964) |
| Verify Administrator password field - character set  | 1. Fill field with accepted character set <BR> 2. Fill in other fields <BR> 3. Click Install button | Install should succeed and account should be accessible via login | |


#### Advanced Options
_Setup_: In the PE console, navigate to Integrations:

|  Test Name |  Steps |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify resolvable_hostname parameter - should override certname | 1. Create CD4PE host with unresolvable certname and resolvable altname <BR> 2. Add resolvable_hostname parameter with altname value <BR> 3. Fill in other fields 4. Click Run Job button | Install should succeed | |
| Verify cd4pe_image parameter - should use specified image | 1. Add cd4pe_image parameter with 'hello-world' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail reporting usage of 'hello-world' docker image | |
| Verify cd4pe_version parameter - should install older cd4pe version | 1. Add cd4pe_version parameter with '1.1.1' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and installed version should be '1.1.1' | |
| Verify cd4pe_version parameter - should provide understandable error | 1. Add cd4pe_version parameter with '99.99.99' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that specified version cannot be found | [CDPE-1965](https://tickets.puppetlabs.com/browse/CDPE-1965) |


##### Database Options
_Setup_: In the PE console, navigate to Integrations:

_Parameters_:

_DOCS_: [CDPE-1966](https://tickets.puppetlabs.com/browse/CDPE-1966)

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
| Verify db_port parameter - should succeed when available | 1. Add db_port parameter with '8000' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should succeed and DDB should be used for storage using 'cd4pe' database | [CDPE-1984](https://tickets.puppetlabs.com/browse/CDPE-1984) |
| Verify db_port parameter - should provide understandable error (unset) | 1. Do not add db_port parameter <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that `db_port` must be set when?? | What is the key indicator that dynamodb is the desired provider since `db_provider` does not support this value? |
| Verify db_port parameter - should provide understandable error (unavailable) | 1. Add db_port parameter with '21' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that could not connect to host | |
| Verify db_port parameter - should provide understandable error (invalid) | 1. Add db_port parameter with 'invalid' value <BR> 2. Add db_host parameter with 'foo' value <BR> 3. Add db_name parameter with 'cd4pe' value <BR> 4. Add db_pass parameter with 'bar' value <BR> 5. Fill in other fields <BR> 6. Click Run Job button | Install should fail, reporting that `db_port` only supports port numbers in [specified range] |


###### MySQL
_Setup_:
* Create MySQL instance
  * TODO: Detailed steps here
  * Set db_host=foo
  * Set db_user=foo
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
| Verify manage_database parameter - should succeed (true - no provider) | 1. Add manage_database parameter with 'true' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed defaulting to using postgresql | |
| Verify manage_database parameter - should provide understandable error (false) | 1. Add manage_database parameter with 'false' value <BR>  2. Fill in other fields <BR> 4. Click Run Job button | Install should fail, reporting cannot connect to an existing db | |
| Verify db_host parameter - should succeed when available | 1. Add db_host parameter with 'foo' value <BR> 2. Add manage_database parameter with 'true' value <BR>  4. Add db_user parameter with 'foo' value <BR> 4. Add db_name parameter with 'cd4pe' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '3306' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should succeed and MySQL should be used for storage on host 'foo' |
| Verify db_host parameter - shou(unset) | | | What is the expected behaviour since this is optional? |
| Verify db_host parameter - should provide understandable error (unavailable) | 1. Add db_host parameter with 'bogus' value <BR> 2. Add manage_database parameter with 'true' value <BR>  4. Add db_name parameter with 'cd4pe' value <BR> 5. Add db_pass parameter with 'bar' value <BR> 6. Add db_port parameter with '3306' value <BR> 7. Fill in other fields <BR> 8. Click Run Job button | Install should fail, reporting that hostname is unreachable |
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
| Verify agent_service_port parameter - should provide understandable error (previously bound) | 1. Add agent_service_port parameter with '22' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail reporting that port is already bound | [CDPE-1969](https://tickets.puppetlabs.com/browse/CDPE-1969) |
| Verify agent_service_port parameter - should provide understandable error (invalid) | 1. Add agent_service_port parameter with 'invalid' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that parameter only supports port numbers in [specified range] | |
| Verify agent_service_port parameter - should provide understandable error (out of range) | 1. Add agent_service_port parameter with '65536' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that parameter only supports port numbers in specified range (1-65535) | [CDPE-1970](https://tickets.puppetlabs.com/browse/CDPE-1970) |
| Verify backend_service_port parameter - should bind to given port | 1. Add backend_service_port parameter with '8010' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and service should be bound to port '8010' | |
| Verify backend_service_port parameter - should provide understandable error (previously bound) | 1. Add backend_service_port parameter with '22' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail reporting that port is already bound | [CDPE-1969](https://tickets.puppetlabs.com/browse/CDPE-1969) |
| Verify backent_service_port parameter - should provide understandable error (invalid) | 1. Add backend_service_port parameter with 'invalid' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that parameter only supports port numbers in [specified range] | |
| Verify backend_service_port parameter - should provide understandable error (out of range) | 1. Add backend_service_port parameter with '65536' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that parameter only supports port numbers in specified range (1-65535) | [CDPE-1970](https://tickets.puppetlabs.com/browse/CDPE-1970) |
| Verify web_ui_port parameter - should bind to given port | 1. Add web_ui_port parameter with '80' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and service should be bound to port '80' | |
| Verify web_ui_port parameter - should provide understandable error (previously bound) | 1. Add web_ui_port parameter with '22' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail reporting that port is already bound | [CDPE-1969](https://tickets.puppetlabs.com/browse/CDPE-1969) |
| Verify web_ui_port parameter - should provide understandable error (invalid) | 1. Add web_ui_port parameter with 'invalid' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that parameter only supports port numbers in [specified range] | |
| Verify web_ui_port parameter - should provide understandable error (out of range) | 1. Add web_ui_port parameter with '65536' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail, reporting that parameter only supports port numbers in specified range (1-65535) | [CDPE-1970](https://tickets.puppetlabs.com/browse/CDPE-1970) |


##### Other Options
_Parameters_:
* cd4pe_docker_extra_params
* analytics

_DOCS_:
* [CDPE-1971](https://tickets.puppetlabs.com/browse/CDPE-1971)

|  Test Name |  Steps |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify cd4pe_docker_extra_params parameter - should pass value to docker command | 1. Add cd4pe_docker_extra_params parameter with '["--name=foobar"]' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and the docker instance should be named 'foobar' | [CDPE-1972](https://tickets.puppetlabs.com/browse/CDPE-1972) |
| Verify analytics parameter - should enable analytics if true | 1. Add analytics parameter with 'true' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and analytics should be enabled | |
| Verify analytics parameter - should disable analytics if false | 1. Add analytics parameter with 'false' value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should succeed and analytics should be disabled | [CDPE-1973](https://tickets.puppetlabs.com/browse/CDPE-1973) |
| Verify analytics parameter - should provide understandable error (invalid) | 1. Add analytics parameter with "evil'ex" value <BR> 2. Fill in other fields <BR> 3. Click Run Job button | Install should fail reporting that "evil'ex" is not a valid value for analytics | |


### Via PE Integrations (2019.0.x or 2018.1.x)


#### Environment Setup
1. Deploy PE 2018.1.8
   * TODO: Detailed steps here
1. Provision node to be dedicated to CD4PE to run on
   * TODO: Detailed steps here
1. Add node to PE; Accept key; run puppet on node
   * TODO: Detailed steps here


#### Basic
_Setup_: In the PE console, navigate to Integrations:

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify documentation link | 1. Click '...get started with Continuous Delivery...' link  | Browser should open CD4PE installation instructions on https://puppet.com/docs in a new tab | |
| Verify install button | 1. Click Install button | Run task page should be displayed with 1. The Task field pre-populated with 'pe_installer_cd4pe::install' <BR> 2. The 'cd4pe_admin_email' and 'cd4pe_admin_password' parameters highlighted as mandatory | |
| Add node to task inventory | 1. Successfully complete the 'Verify install button' test <BR> 2. Add cd4pe node to task inventory | | This is a setup task for the tests below |
| Verify cd4pe_admin_email parameter - minimum (1) | 1. Successfully complete the 'Add node to task inventory' test <BR> 2. Fill in field with '""' <BR> 3. Fill in other fields  <BR> 3. Click Run Job button | Task should fail reporting that parameter requires a string of at least one character | |
| Verify cd4pe_admin_email parameter - maximum (385) | 1. Successfully complete the 'Add node to task inventory' test <BR> 2. Fill in field with a string exceeding maximum  <BR> 3. Fill in other fields  <BR> 3. Click Run Job button | Task should fail reporting that parameter requires a string not exceeding maximum | local(64)@domain(255).tld(63) See: [Email spec ref 1](https://tools.ietf.org/html/rfc822#section-6.1) [Email spec ref 2](https://tools.ietf.org/html/rfc1035), [CDPE-1974](https://tickets.puppetlabs.com/browse/CDPE-1974)  |
| Verify cd4pe_admin_password parameter - minimum (1) | 1. Successfully complete the 'Add node to task inventory' test <BR> 2. Fill in field with '""' <BR> 3. Fill in other fields  <BR> 3. Click Run Job button | Task should fail reporting that parameter requires a string of at least one character | |
| Verify cd4pe_admin_password parameter - maximum (?) | 1. Successfully complete the 'Add node to task inventory' test <BR> 2. Fill in field with a string exceeding maximum  <BR> 3. Fill in other fields  <BR> 3. Click Run Job button | Task should fail reporting that parameter requires a string not exceeding maximum | |


#### Advanced Options
See [Integrations 2019.1.x Advanced](#2019-advanced)


### Via CD4PE Module
_Setup_:

1. Deploy PE (version agnostic)
   * TODO: Detailed steps here
1. Setup control repo on master
   * `bolt command run 'yum install -y git' --user root --no-host-key-check --private-key ~/.ssh/id_rsa-acceptance --nodes <pe-master>`
   * (via [gplt bolt task](https://github.com/puppetlabs/gatling-puppet-load-test/blob/master/docs/tasks.md#gpltcreate_control_repo_from_production_env))  `bolt task run  --user root --no-host-key-check --private-key ~/.ssh/id_rsa-acceptance  gplt::create_control_repo_from_production_env --nodes <pe-master>`
   * `bolt command run 'git clone /opt/puppet/control-repo.git && cd control-repo /root/control-repo' --user root --no-host-key-check --private-key ~/.ssh/id_rsa-acceptance --nodes <pe-master>`
   * Create Puppetfile
   ```
   cat > puppetfile.pp << PUPPETFILE
   file { '/root/control-repo/Puppetfile':
     ensure => present,
     content => "
       mod 'puppetlabs-cd4pe', :latest
       mod 'puppetlabs-concat', '4.2.1'
       mod 'puppetlabs-hocon', '1.0.1'
       mod 'puppetlabs-puppet_authorization', '0.5.0'
       mod 'puppetlabs-stdlib', '4.25.1'
       mod 'puppetlabs-docker', '3.3.0'
       mod 'puppetlabs-apt', '6.2.1'
       mod 'puppetlabs-translate', '1.1.0'
     ",
   }
   PUPPETFILE
   ```
   * `bolt apply puppetfile.pp --user root --no-host-key-check --private-key ~/.ssh/id_rsa-acceptance --nodes <pe-master>`
   * `bolt command run 'cd /root/control-repo && git add Puppetfile' --user root --no-host-key-check --private-key ~/.ssh/id_rsa-acceptance --nodes <pe-master>`
   * `bolt command run 'cd /root/control-repo && git commit -m "Add Puppetfile"' --user root --no-host-key-check --private-key ~/.ssh/id_rsa-acceptance --nodes <pe-master>`
   * `bolt command run 'cd /root/control-repo && git push' --user root --no-host-key-check --private-key ~/.ssh/id_rsa-acceptance --nodes <pe-master>`
   * [Enable code manager](https://puppet.com/docs/pe/2019.1/code_mgr_config.html#enable-code-manager-after-installation)
     * Add `code_manager_auto_configure` to `true` to `puppet_enterprise::profile::master` class in PE Master group
     * Add `r10k_remote` to `/opt/puppet/control-repo.git` to `puppet_enterprise::profile::master` class in PE Master group
     * Run puppet on master
   * Deploy. SSH to master and perform the following:
     * `puppet access login`
     * `puppet code deploy production --wait`
1. Create CD4PE node group
1. Provision node to be dedicated to CD4PE to run on
   * Via VMPooler/VMFloaty: `floaty get redhat-7-x86_64`
1. Add node to PE; Accept key; run puppet on node
   * TODO: Detailed steps here
1. Pin node to CD4PE node group
1. Add cd4pe class to classification tab of CD4PE node group
1. Run puppet on cd4pe node
   * Nodes on vmpooler will fail to install docker due to rhel mirrors not being available. Install docker via `yum -y --enablerepo=localmirror-extras install docker-ce` and re-run puppet.

Test cd4pe class pararameter.  See  [Integrations 2019.1.x Advanced](#2019-advanced)

_DOCS_:
* [CDPE-1981](https://tickets.puppetlabs.com/browse/CDPE-1981)

### Via Docker
_Setup_:

1. Deploy PE (version agnostic)
   * TODO: Detailed steps here
1. Provision node to be dedicated to CD4PE to run on
   * Via VMPooler/VMFloaty: `floaty get redhat-7-x86_64`
1. Add node to PE; Accept key; run puppet on node
   * TODO: Detailed steps here
1. Install Docker on node
   * `puppet module install puppetlabs-docker`
   * `puppet apply -e "class { 'docker': repo_opt => '--enablerepo=localmirror-extras', }"`
1. Setup MySQL database on node
   * `docker pull mysql:5.7`
   * `docker run --name mysqldbtest -e MYSQL_ROOT_PASSWORD=mypass -e MYSQL_DATABASE=cdpe -e MYSQL_USER=cdpe -e MYSQL_PASSWORD=mypass -d mysql:5.7 --character-set-server=latin1 --collation-server=latin1_swedish_ci`
   * Get mysql container's IP address
     * `export mysqlip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysqldbtest)`
1. Generate encryption key
   * `export secret=$(dd bs=1 if=/dev/urandom count=16 2>/dev/null | base64)`


|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify docker pull | 1. SSH to CD4PE node <BR> 2. Run `docker pull puppet/continuous-delivery-for-puppet-enterprise:latest` | 1. Command should complete with '0' exit code <BR> 2. STDOUT should contain 'Status: Downloaded newer image' **OR** 'Status: Image is up to date' | |
| Verify docker run | 1. SSH to CD4PE node <BR> 2. Run `docker run --rm --name cd4pe -v cd4pe:/disk -e DB_ENDPOINT=mysql://$mysqlip:3306/cdpe -e DB_USER=cdpe -e DB_PASS=mypass -e DB_PREFIX=cdpe_ -e DUMP_URI=dump://localhost:7000 -e PFI_SECRET_KEY=$secret -p 8080:8080 -p 8000:8000 -p 7000:7000 puppet/continuous-delivery-for-puppet-enterprise:latest` | 1. Command should complete with '0' exit code <BR> 2. STDOUT should return a Docker container ID | [CDPE-1982](https://tickets.puppetlabs.com/browse/CDPE-1982) |
| Verify cd4pe running | 1. Successfully complete 'Verify docker run' test <BR> 2. Point web browser to `<cd4pe-docker-host>:8080` | CD4PE setup page should be displayed | |


## Initial Login


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
| Verify license - should provide understandable error (invalid json) | 1. Create empty text file on local machine <BR> 2. Navigate to `http://<cd4pe-instance.:<web-ui-port>/configure`  <BR> 3. Click 'License' 4. Click Choose button 5. Select file 6. Click Submit License button | License application should fail, reporting that license file is invalid  | [CDPE-1984](https://tickets.puppetlabs.com/browse/CDPE-1984) |
| Verify license - should provide understandable error (invalid license schema) | 1. Create json file on local machine with contents of '{}' <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/configure`  <BR> 3. Click 'License' 4. Click Choose button 5. Select file 6. Click Submit License button | License application should fail, reporting that license file is invalid  | [CDPE-1985](https://tickets.puppetlabs.com/browse/CDPE-1985) |
| Verify license - should provide understandable error (invalid license) | 1. Create json file on local machine with contents of '{ "document": { "address": "", "companyName": "", "contactEmail": "", "contactName": "", "created": "", "eula": "", "expiration": "", "id": "", "nodes": "", "projects": "", "servers": "", "type": "" }, "signature": "", "eula": "" }' <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/configure`  <BR> 3. Click 'License' 4. Click Choose button 5. Select file 6. Click Submit License button | License application should fail, reporting that license is invalid  | |
| Verify login - should reject invalid credentials (root) | 1. Submit valid license file 2. Click 'or continue to manage configurations as root' 3. Enter 'foo' in Email field 4. Enter 'bar' in Password field 5. Click  Sign In button | Login should fail, reporting that credentials are unknown | |
| Verify login - should accept valid credentials (root) | 1. Submit valid license file 2. Click 'or continue to manage configurations as root' 3. Enter email used during installation in Email field 4. Enter password used during installation in Password field 5. Click  Sign In button | Login should succeed | [CDPE-1986](https://tickets.puppetlabs.com/browse/CDPE-1986) |


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
| Verify Email field - should accept UTF-8 in local | 1. Fill field with email '©®@a.b' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Email field - should reject malformed email address | 1. Fill field with "evil'ex" <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting that the field must be valid email | |
| Verify Email field - should accept local of 64 chars | 1. Fill field with 'MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlis@example.org' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Email field - local must not exceed 64 chars | 1. Fill field with 'MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistment@example.org' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting that the field must be valid email | |
| Verify Email field - should accept domain of 255 chars | 1. Fill field with 'user@MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistmentVaudevilleLatishaDecriedJovianLenghtwiseTroubleshooterClamberCaterersAnthropologistGarbedSlicerExpediencyBroodingPilafRiddlesForthcomingUnkindlierTitanicAlzheimerDoubterDumpedFifesMe.org' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should succeed and account should be accessible via login | |
| Verify Email field - domain must not exceed 255 chars | 1. Fill field with 'user@MalignPreyOiledPalmFireSomeAddictPygmyEntitlementSpikesEnlistmentVaudevilleLatishaDecriedJovianLenghtwiseTroubleshooterClamberCaterersAnthropologistGarbedSlicerExpediencyBroodingPilafRiddlesForthcomingUnkindlierTitanicAlzheimerDoubterDumpedFifesMel.org' <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting that the field must be valid email | [CDPE-1987](https://tickets.puppetlabs.com/browse/CDPE-1987) |
| Verify Username field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Sign up button | Account creation should fail, reporting that the field must be populated | |
| Verify Username field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Sign Up button | Account creation should fail, reporting the maximum acceptable length | [CDPE-1988](https://tickets.puppetlabs.com/browse/CDPE-1988) |
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


### Azure DevOps
[Doc](https://puppet.com/docs/continuous-delivery/2.x/integrations.html#integrate-azure-devops)

_Root Setup_:
* Create Azure Oauth application (instructions out of scope)
* Integrate azure with cd4pe
  * Login as root
  * Navigate to `http://<cd4pe-instance>:<web-ui-port>/root/settings`
  * Click Integrations link

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify ADO integration - valid | 1. Fill Client ID field with valid value <BR> 2. Fill Client Secret field with valid value <BR> 3. Click Add link <BR> 4. Click Add Integration button | Integration should succeed (How can integration be verified?). | |
| Verify ADO integration - invalid | 1. Fill Client ID field with invalid value <BR> 2. Fill Client Secret field with invalid value <BR> 3. Click Add link <BR> 4. Click Add Integration button | Integration should fail, reporting unable to authenticate with OAuth application | |
| Verify ADO integration - removal | 1. Fill Client ID field with valid value <BR> 2. Fill Client Secret field with valid value <BR> 3. Click Add link <BR> 4. Click Remove link <BR> 5. Click Remove Integration button | Integration should be successfully removed | |
| Verify Client ID field - minimum (1)  | 1. Leave Client ID field blank <BR> 2. Fill Client Secret field with valid value <BR> 3. Click Add link | Add link should be disabled | |
| Verify Client Secret field - minimum (1)  | 1. Fill Client ID field with valid value <BR> 2. Leave Client Secret field blank <BR> 3. Click Add link | Add link should be disabled | |

_User Setup_:
* Login as user
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/settings`
* Click Source Control link

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify ADO settings link | 1. Click Azure DevOps link <BR> | 'Azure DevOps Credentials' modal should appear | |
| Verify ADO credentials button | 1. Successfully perform 'Verify ADO settings link' test <BR> 2. Click Add Credentials button | Browser should redirect to Azure DevOps login page | |
| Verify ADO login | 1. Successfully perform 'Verify ADO credentials button' test <BR> 2. Login to Azure DevOps | Browser should redirect to CD4PE | |


### Bitbucket  <a id="vcs-bbucket"></a>
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
| Verify integration - valid | 1. Fill Client ID field with valid value <BR> 2. Fill Client Secret field with valid value <BR> 3. Click Add link 4. Click Add Integration button | Integration should succeed (How can integration be verified?). | |
| Verify integration - invalid | 1. Fill Client ID field with invalid value <BR> 2. Fill Client Secret field with invalid value <BR> 3. Click Add link 4. Click Add Integration button | Integration should fail, reporting unable to authenticate with OAuth application | |
| Verify integration - removal | 1. Fill Client ID field with valid value <BR> 2. Fill Client Secret field with valid value <BR> 3. Click Add link 4. Click Remove link 5. Click Remove Integration button | Integration should be successfully removed | |
| Verify Client ID field - minimum (1)  | 1. Leave Client ID field blank <BR> 2. Fill Client Secret field with valid value <BR> 3. Click Add link | Add link should be disabled | |
| Verify Client Secret field - minimum (1)  | 1. Fill Client ID field with valid value <BR> 2. Leave Client Secret field blank <BR> 3. Click Add link | Add link should be disabled | |



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

_DOCS_:
* [CDPE-2024](https://tickets.puppetlabs.com/browse/CDPE-2024)

_Docs_: It should be pointed out in the [docs](https://puppet.com/docs/continuous-delivery/2.x/integrate_with_puppet_enterprise.html#task-7458) that this step cannot be performed by the CD4PE "root" user.

_Setup_:
* Login to CD4PE as a non-root user
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/settings/puppet-enterprise`
* Click Add Credentials button

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify required fields - must be filled in | 1. Leave all fields blank <BR> 2. Click Save Changes button | Credential setting should fail, reporting that the required fields have not been populated | |
| Verify Name field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify Name field - maximum (2712)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting the maximum acceptable length | [CDPE-2026](https://tickets.puppetlabs.com/browse/CDPE-2026) |
| Verify Name field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | [CDPE-2025](https://tickets.puppetlabs.com/browse/CDPE-2025) |
| Verify PE console address field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify PE console address field - invalid url  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that value is an invalid url | [CDPE-2027](https://tickets.puppetlabs.com/browse/CDPE-2027) |
| Verify PE console address field - Supports multilingual domain  | 1. Fill field with 'http://스타벅스코리아.com/' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should resolve the domain (116.126.86.86) but fail to authenticate | [CDPE-2028](https://tickets.puppetlabs.com/browse/CDPE-2028) |
| Verify PE console address field - should protect against semantic url attacks   | 1. Fill field with 'https://my.pe.server.org/evil/endpoint?resetpassord=true&user=admin' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that value is an invalid url | |
| Verify PE console address field - valid  | 1. Fill field with 'https://<pe-console-server>' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Username field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify Username field - maximum (254)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting the maximum acceptable length | [CDPE-2029](https://tickets.puppetlabs.com/browse/CDPE-2029) |
| Verify Username field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Username field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Password field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify Password field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting the maximum acceptable length | |
| Verify Password field - character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Password field - valid  | 1. Fill field with 'a' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify Token Lifetime (months/years) fields - exclusive (months) | 1. Fill years field with '1' <BR> 2. Fill in months field with '1' | Months field should override years field| |
| Verify Token Lifetime (months/years) fields - exclusive (years) | 1. Fill months field with '1' <BR> 2. Fill in years field with '1' | Years field should override months field| |
| Verify Token Lifetime (months) field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields except for Token Lifetime (Years) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | [CDPE-2030](https://tickets.puppetlabs.com/browse/CDPE-2030) |
| Verify Token Lifetime (months) field - non-zero | 1. Fill field with '0' <BR> 2. Fill in other fields except for Token Lifetime (Years) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | |
| Verify Token Lifetime (months) field - positive | 1. Fill field with '-1' <BR> 2. Fill in other fields except for Token Lifetime (Years) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | |
| Verify Token Lifetime (months) field - number | 1. Fill field with 'hello' <BR> 2. Fill in other fields except for Token Lifetime (Years) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | [CDPE-2031](https://tickets.puppetlabs.com/browse/CDPE-2031) |
| Verify Token Lifetime (months) field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields except for Token Lifetime (Years)<BR> 3. Click Save Changes button | Credential setting should fail, reporting the maximum acceptable length | [CDPE-2032](https://tickets.puppetlabs.com/browse/CDPE-2032) |
| Verify Token Lifetime (months) field - Valid  | 1. Fill field with '1' <BR> 2. Fill in other fields except for Token Lifetime (Years)<BR> 3. Click Save Changes button |  Credential setting should proceed to verify PE authentication | |
| Verify Token Lifetime (years) field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields except for Token Lifetime (Months) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | [CDPE-2030](https://tickets.puppetlabs.com/browse/CDPE-2030) |
| Verify Token Lifetime (years) field - non-zero | 1. Fill field with '0' <BR> 2. Fill in other fields except for Token Lifetime (Months) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | |
| Verify Token Lifetime (years) field - positive | 1. Fill field with '-1' <BR> 2. Fill in other fields except for Token Lifetime (Months) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | |
| Verify Token Lifetime (years) field - number | 1. Fill field with 'hello' <BR> 2. Fill in other fields except for Token Lifetime (Months) <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be greater than zero | [CDPE-2031](https://tickets.puppetlabs.com/browse/CDPE-2031) |
| Verify Token Lifetime (years) field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields except for Token Lifetime (Months)<BR> 3. Click Save Changes button | Credential setting should fail, reporting the maximum acceptable length | [CDPE-2032](https://tickets.puppetlabs.com/browse/CDPE-2032) |
| Verify Token Lifetime (years) field - Valid  | 1. Fill field with '1' <BR> 2. Fill in other fields except for Token Lifetime (Months)<BR> 3. Click Save Changes button |  Credential setting should proceed to verify PE authentication | |
| Verify API Token field - minimum (1) | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting that the field must be populated | |
| Verify API Token field - maximum (45)  | 1. Fill field with string exceeding 45 characters <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting an invalid token was entered | |
| Verify API Token field - invalid character set (utf-8)  | 1. Fill field with '©®' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should fail, reporting an invalid token was entered | [CDPE-2033](https://tickets.puppetlabs.com/browse/CDPE-2033) |
| Verify API Token field - valid  | 1. Fill field with '0DN133wZZvN4ZEqLgYW8Gzmk4u1l5vmswlwgqpdBY1Ls' <BR> 2. Fill in other fields <BR> 3. Click Save Changes button | Credential setting should proceed to verify PE authentication | |
| Verify integration - valid  | 1. Fill all fields with legit PE credentials  <BR> 2. Click Save Changes button | Credential setting should succeed PE authentication | |


## Control Repo Setup
[Docs](https://puppet.com/docs/continuous-delivery/2.x/setting_up.html#task-3948)

_DOCS_:
 * [CDPE-2048](https://tickets.puppetlabs.com/browse/CDPE-2048)


### Azure DevOps
_Setup_:
* Create Azure DevOps control repo
* Enable source control integration for appropriate Azure DevOps
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories`
* Click Add Control Repo button

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify OAuth redirect | 1. Select 'Azure DevOps' from list <BR> 2. Click Add Credentials button | Browser should be redirected to Azure DevOps login page | |
| Verify organization redirect | 1. Successfully perform 'Verify OAuth redirect' test <BR> 2. Login to Azure DevOps | Browser should be redirected to cd4pe 'Add Control Repo' dialog with a 'Select Organization' prompt containing the user and organizations associated with the Azure DevOps OAuth application | |
| Verify organization selection | 1. Successfully perform 'Verify organization redirect' test <BR> 2. Select username in 'Select organization' list | 'Select repository' selection should appear | |
| Verify repository selection | 1. Successfully perform 'Verify organization selection' test <BR> 2. Select control repo in 'Select repository' list | 'Create master branch from' selection should appear | [CDPE-2049](https://tickets.puppetlabs.com/browse/CDPE-2049) |
| Verify create master branch from selection | 1. Successfully perform 'Verify repository selection' test <BR> 2. Select the main branch in 'Select branch' list  | 1. 'Control repo name' field should appear and be pre-populated with the control repo name <BR> 2. 'Add' button should appear | |
| Verify add control repo | 1. Successfully perform 'Verify create master branch from selection' test <BR> 2. Click Add button | Control repo object should be created in CD4PE and browser should be redirected to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories/<repo-name>`| |
| Verify delete control repo | 1. Successfully perform 'Verify add control repo' test <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories` 3. Click trash-can icon for control repo | Deletion confirmation modal should appear
| Verify delete control repo button | 1. Successfully perform 'Verify delete control repo' test <BR> 2. Click Delete button | Control repo should be absent from list | |
| Verify no control repos | 1. Delete all control repos | 1. Control repo list should be empty <BR> 2. 'Add control repository' step in setup checklist should be unchecked | |


### Bitbucket
_Setup_:
* Create [Bitbucket integration for workspace](#vcs-bbucket)
* Create Bitbucket control repo
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories`
* Click Add Control Repo button

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify source control selection | 1. Select 'Bitbucket Server' from list | 'Select organization' selection should appear | |
| Verify organization selection | 1. Successfully perform 'Verify source control selection' test <BR>  2. Select username in 'Select organization' list | 'Select repository' selection should appear | |
| Verify repository selection | 1. Successfully perform 'Verify organization selection' test <BR>  2. Select control repo in 'Select repository' list | 'Create master branch from' selection should appear | [CDPE-2049](https://tickets.puppetlabs.com/browse/CDPE-2049) |
| Verify create master branch from selection | 1. Successfully perform 'Verify repository selection' test <BR> 2. Select the main branch in 'Select branch' list  | 1. 'Control repo name' field should appear and be pre-populated with the control repo name <BR> 2. 'Add' button should appear | |
| Verify add control repo | 1. Successfully perform 'Verify create master branch from selection' test <BR> 2. Click Add button | Control repo object should be created in CD4PE and browser should be redirected to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories/<repo-name>`| |
| Verify delete control repo | 1. Successfully perform 'Verify add control repo' test <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories` 3. Click trash-can icon for control repo | Deletion confirmation modal should appear
| Verify delete control repo button | 1. Successfully perform 'Verify delete control repo' test <BR> 2. Click Delete button | Control repo should be absent from list | |
| Verify no control repos | 1. Delete all control repos | 1. Control repo list should be empty <BR> 2. 'Add control repository' step in setup checklist should be unchecked | |


### GitHub

_Setup_:
* Create GitHub control repo
* Enable source control integration for appropriate GitHub
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories`
* Click Add Control Repo button

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify OAuth redirect | 1. Select 'GitHub' from list <BR> 2. Click Add Credentials button | Browser should be redirected to GitHub OAuth Application authorization page: <BR> * _Organizations and teams_ should set to 'Read-only access' <BR> _Repositories_ should be set to 'Public and private' <BR> _Personal User Data_ should be set to 'Email addresses (read-only)' | |
| Verify organization redirect | 1. Successfully perform 'Verify OAuth redirect' test <BR> 2. Click 'Authorize' button <BR> 3. Submit GitHub password if instructed | Browser should be redirected to cd4pe 'Add Control Repo' dialog with a 'Select Organization' prompt containing the user and organizations associated with the GitHub OAuth application | |
| Verify organization selection | 1. Successfully perform 'Verify organization redirect' test <BR> 2. Select username in 'Select organization' list | 'Select repository' selection should appear | |
| Verify repository selection | 1. Successfully perform 'Verify organization selection' test <BR> 2. Select control repo in 'Select repository' list | 'Create master branch from' selection should appear | [CDPE-2049](https://tickets.puppetlabs.com/browse/CDPE-2049) |
| Verify create master branch from selection | 1. Successfully perform 'Verify repository selection' test <BR> 2. Select the main branch in 'Select branch' list  | 1. 'Control repo name' field should appear and be pre-populated with the control repo name <BR> 2. 'Add' button should appear | |
| Verify add control repo | 1. Successfully perform 'Verify create master branch from selection' test <BR> 2. Click Add button | Control repo object should be created in CD4PE and browser should be redirected to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories/<repo-name>`| |
| Verify delete control repo | 1. Successfully perform 'Verify add control repo' test <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories` 3. Click trash-can icon for control repo | Deletion confirmation modal should appear
| Verify delete control repo button | 1. Successfully perform 'Verify delete control repo' test <BR> 2. Click Delete button | Control repo should be absent from list | |
| Verify no control repos | 1. Delete all control repos | 1. Control repo list should be empty <BR> 2. 'Add control repository' step in setup checklist should be unchecked | |


### GitHub Enterprise
TBD

### GitLab
_Setup_:
* Create [GitLab server](#vcs-gitlab)
* Create GitLab control repo
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories`
* Click Add Control Repo button

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify source control selection | 1. Select 'GitLab' from list | 'Select organization' selection should appear | |
| Verify organization selection | 1. Successfully perform 'Verify source control selection' test <BR>  2. Select username in 'Select organization' list | 'Select repository' selection should appear | [CDPE-2054](https://tickets.puppetlabs.com/browse/CDPE-2054) |
| Verify repository selection | 1. Successfully perform 'Verify organization selection' test <BR>  2. Select control repo in 'Select repository' list | 'Create master branch from' selection should appear | [CDPE-2049](https://tickets.puppetlabs.com/browse/CDPE-2049) |
| Verify create master branch from selection | 1. Successfully perform 'Verify repository selection' test <BR> 2. Select the main branch in 'Select branch' list  | 1. 'Control repo name' field should appear and be pre-populated with the control repo name <BR> 2. 'Add' button should appear | |
| Verify add control repo | 1. Successfully perform 'Verify create master branch from selection' test <BR> 2. Click Add button | Control repo object should be created in CD4PE and browser should be redirected to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories/<repo-name>`| |
| Verify delete control repo | 1. Successfully perform 'Verify add control repo' test <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories` 3. Click trash-can icon for control repo | Deletion confirmation modal should appear
| Verify delete control repo button | 1. Successfully perform 'Verify delete control repo' test <BR> 2. Click Delete button | Control repo should be absent from list | |
| Verify no control repos | 1. Delete all control repos | 1. Control repo list should be empty <BR> 2. 'Add control repository' step in setup checklist should be unchecked | |


## Add Job Hardware
[Docs](https://puppet.com/docs/continuous-delivery/2.x/configure_job_hardware.html)

_DOCS_:
* [CDPE-2055](https://tickets.puppetlabs.com/browse/CDPE-2055)

_Setup_:
* Provision linux host
  * Install git
  {noformat}
  yum install -y git
  {noformat}
  * Install docker
  {noformat}
  yum remove docker \
             docker-client \
             docker-client-latest \
             docker-common \
             docker-latest \
             docker-latest-logrotate \
             docker-logrotate \
             docker-engine
  yum install -y yum-utils \
                 device-mapper-persistent-data \
                 lvm2
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install docker-ce docker-ce-cli containerd.io
  systemctl start docker
  {noformat}
* Provision windows host
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/job-hardware`

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify Add Job Hardware button (\*nix) | 1. Click Add Job Hardware button | Modal should appear with shell commands listed for \*nix by default | [CDPE-2056](https://tickets.puppetlabs.com/browse/CDPE-2056) |
| Verify Add Job Hardware button (windows) | 1. Successfully perform 'Verify Add Job Hardware button (\*nix)' test <BR>  2. Click 'Windows' link | Shell commands listed for windows should appear | [CDPE-2057](https://tickets.puppetlabs.com/browse/CDPE-2057), [CDPE-2058](https://tickets.puppetlabs.com/browse/CDPE-2058) |
| Verify distelli install (\*nix) | 1. Successfully perform 'Verify Add Job Hardware button (\*nix)' test <BR>  2. SSH to linux host as root <BR>  3. Run first command displayed in CD4PE | Command should successfully complete;  STDOUT should include `To install the agent, run` | |
| Verify distelli agent install (\*nix) | 1. Successfully perform 'Verify distelli install (\*nix)' test <BR>  2. SSH to linux host as root <BR>  3. Run second command displayed in CD4PE | Command should successfully complete;  STDOUT should include `Starting Distelli supervisor` | |
| Verify distelli agent install (\*nix distelli.yml)  | 1. Successfully perform 'Verify distelli install (\*nix)' test <BR>  2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/settings/agent` <BR>  3. Click 'Create Credential' link <BR>  4. SSH to linux host as root <BR> 5. Create a `distelli.yml` file on the host containing `---\nDistelliAccessToken: <MY_ACCESS_TOKEN>\nDistelliSecretKey: <MY_SECRET_KEY>` where the token and key are copied from the generated credential in step 3 <BR> 6. Run second command displayed in CD4PE, appending `-conf <PATH_TO_DISTELLI.YML_FILE>` to the command | Command should successfully complete;  STDOUT should include `To install the agent, run` | |
| Verify distelli install (windows) | 1. Successfully perform 'Verify Add Job Hardware button (windows)' test <BR>  2. Remote Desktop to windows host as Administrator <BR>  3. Run first command displayed in CD4PE in a command window | Command should successfully complete; STDOUT should include `To install the agent, run` | |
| Verify distelli agent install (windows) | 1. Successfully perform 'Verify distelli install (windows)' test <BR>  2. Remote Desktop to windows host as Administrator <BR>  3. Run second command displayed in CD4PE in a command window | Command should successfully complete; | |
| Verify distelli agent install (windows distelli.yml)  | 1. Successfully perform 'Verify distelli install (windows)' test <BR>  2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/settings/agent` <BR>  3. Click 'Create Credential' link <BR>  4. Remote Desktop to windows host as Administrator <BR> 5. Create a `distelli.yml` file on the host containing `---\r\nDistelliAccessToken: <MY_ACCESS_TOKEN>\r\nDistelliSecretKey: <MY_SECRET_KEY>` where the token and key are copied from the generated credential in step 3 <BR> 6. Run second command displayed in CD4PE, appending `-conf <PATH_TO_DISTELLI.YML_FILE>` to the command | Command should successfully complete; | _UX_: No indication in output that the command did the needful. |
| Verify Active toggle | 1. Successfully perform 'Verify distelli agent install (\*nix)' test <BR>  2. Reload `http://<cd4pe-instance>:<web-ui-port>/<workspace>/job-hardware` <BR>  3. Click 'Job Hardware Active' | Toggle should turn green | |
| Verify Capability field - minimum (1)  | 1. Successfully perform 'Verify distelli agent install (\*nix)' <BR>  2. Reload `http://<cd4pe-instance>:<web-ui-port>/<workspace>/job-hardware` <BR> 3. Click 'Add Capability' link for hardware <BR>  4. Leave field blank  5. Click Save link | Capability form should remain open | |
| Verify Capability field - maximum (?)  | 1. Successfully perform 'Verify distelli agent install (\*nix)' <BR>  2. Reload `http://<cd4pe-instance>:<web-ui-port>/<workspace>/job-hardware` <BR> 3. Click 'Add Capability' link for hardware <BR>  4. Fill field with string exceeding maximum  5. Click Save link | Entry should be prevented  | |
| Verify Capability field - utf-8  | 1. Successfully perform 'Verify distelli agent install (\*nix)' <BR>  2. Reload `http://<cd4pe-instance>:<web-ui-port>/<workspace>/job-hardware` <BR> 3. Click 'Add Capability' link for hardware <BR>  4. Fill field with '©®@a.b'  5. Click Save link | Save should succeed | |
| Verify Capability field - db-inject  | 1. Successfully perform 'Verify distelli agent install (\*nix)' <BR>  2. Reload `http://<cd4pe-instance>:<web-ui-port>/<workspace>/job-hardware` <BR> 3. Click 'Add Capability' link for hardware <BR>  4. Fill field with "evil'ex"  5. Click Save link | Save should succeed  | [CDPE-2059](https://tickets.puppetlabs.com/browse/CDPE-2059), [CDPE-2060](https://tickets.puppetlabs.com/browse/CDPE-2060)  |



## Pipelines
[Docs](https://puppet.com/docs/continuous-delivery/2.x/start_building_your_modules_pipeline.html)

_Setup_:
* [Setup control repo](#control-repo-setup)
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories/<repo-name>`

### Create Pipeline
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify Add Pipeline link | 1. Click '+Add Pipeline' link | Modal should appear with 'Single Branch' selected by default and 'Select Branch' selection | |
| Verify pipeline single branch | 1. Successfully perform 'Verify Add Pipeline link' test <BR>  2. Click 'Single Branch' radio button | 'Select Branch' selection should appear | |
| Verify pipeline single branch - unselected | 1. Successfully perform 'Verify Add Pipeline link' test <BR>  2. Click Add Pipeline button | Error should be displayed that a branch must be selected | |
| Verify pipeline single branch - selected | 1. Successfully perform 'Verify Add Pipeline link' test <BR>  2. Select a branch from the 'Select Branch' list <BR>  3. Click Add Pipeline button | The pipeline creation should succeed | |
| Verify pipeline branch regex | 1. Successfully perform 'Verify Add Pipeline link' test <BR>  2. Click 'Branch Regex' radio button | 'Configure regex' field should appear | |
| Verify pipeline branch regex - minimum (1) | 1. Successfully perform 'Verify pipeline branch regex' test <BR>  2. Delete contents of the 'Branch Regex' field <BR>  3. Click Add Pipeline button | Invalid regex error should be displayed | [CDPE-2063](https://tickets.puppetlabs.com/browse/CDPE-2063) |
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
| Verify Add stage job - selected | 1. Successfully perform 'Verify Add stage job' test <BR>  2. Select a job from the 'Select Job' list <BR>  3. Click Add Stage button | The stage creation should succeed and 'add another stage' modal should appear | [CDPE-2064](https://tickets.puppetlabs.com/browse/CDPE-2064)  |
| Verify Add stage deployment | 1. Successfully perform 'Verify Add stage button' test <BR>  2. Click 'Deployment' radio button | 'Select a node group' should appear | |
| Perform tests from [manual deployment modal](#manual) | | | |
| Verify Add stage impact analysis - without deployment | 1. Successfully perform 'Verify Add stage button' test <BR>  2. Click 'Impact Analysis' radio button | Error should appear that this type of stage is not available until a deployment stage has been added | [CDPE-2065](https://tickets.puppetlabs.com/browse/CDPE-2065) |
| Verify Add stage impact analysis - with deployment (immediate radio selection) | 1. Successfully add deployment stage via Direct Deployment policy without clicking Done button  <BR>  2. Click 'Impact Analysis' radio button | Impact analysis modal should appear without error | |
| Verify Add stage impact analysis - with deployment (previously created) | 1. Successfully add deployment stage via Direct Deployment policy <BR>  2. Successfully perform 'Verify Add stack button' test <BR>  3. Click 'Impact Analysis' radio button | Impact analysis modal should appear without error | |
| Verify batch size field (impact analysis) - minimum (1)  | 1. Successfully perform 'Verify Add stage impact analysis - with deployment (previously created)' test  <BR>  2. Delete the contents of the 'Compile up to xx node catalogs' field <BR>  3. Click 'Add Impact Analysis' button | Add Impact Analysis button should be grayed out/unavailable OR error should be displayed indicating that batch size must be set | |
| Verify batch size field (impact analysis) - maximum (?)  | 1. Successfully perform 'Verify Add stage impact analysis - with deployment (previously created)' test  <BR>  2. Enter a number that exceeds the allowed maximum in the 'Compile up to xx node catalogs' field <BR>  3. Click 'Add Impact Analysis' button | Add Impact Analysis button should be grayed out/unavailable OR error should be displayed indicating that the number exceeds the allowed maximum | [CDPE-2066](https://tickets.puppetlabs.com/browse/CDPE-2066) |
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
| Verify Docker Image Name - minimum (1) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Leave Docker Image field blank <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that the Docker Image field must be populated when running the job in a container | [CDPE-2067](https://tickets.puppetlabs.com/browse/CDPE-2067) |
| Verify Docker Image Name - maximum (255) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Image field with string exceeding maximum <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that the Docker Image field must be populated when running the job in a container | [Ref](https://success.docker.com/article/dtr-max-length-repo-name), [CDPE-2068](https://tickets.puppetlabs.com/browse/CDPE-2068)  |
| Verify Docker Image Name - invalid characters | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Image field with 'A☃\\?'  <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that name must conform to specification |[Ref](https://docs.docker.com/registry/spec/api/#overview), [CDPE-2069](https://tickets.puppetlabs.com/browse/CDPE-2069)  |
| Verify Docker Image Name - valid | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Image field with 'a'  <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Docker Run Arguments - minimum (0) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Leave Docker Run Arguments field blank <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should succeed and job should be accessible in jobs list | |
| Verify Docker Run Arguments - maximum (?) | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Run Arguments field with string exceeding maximum <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that the Docker Image field must be populated when running the job in a container | |
| Verify Docker Run Arguments - invalid syntax | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Run Arguments field with 'foobar'  <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that name must conform to --key=value specification |[Ref](https://docs.docker.com/engine/reference/run),  [CDPE-2070](https://tickets.puppetlabs.com/browse/CDPE-2070) |
| Verify Docker Run Arguments - invalid character set | 1. Successfully perform 'Verify New Job button' test <BR>  2. Turn on docker container selection <BR>  3. Fill Docker Run Arguments field with '--☃=y'  <BR>  4. Fill in other fields <BR>  5. Click Create Job button | Job creation should fail, reporting that name must conform to ascii specification |[Ref](https://docs.docker.com/engine/reference/run), [CDPE-2071](https://tickets.puppetlabs.com/browse/CDPE-2071) |
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
    * In the PE console, reject the node's certificate
    * On the agent, submit new cert request: `puppet agent -t`
    * On the master, sign cert request
    * On the agent, apply catalog: `puppet agent -t`

_DOCS_:
* [CDPE-2085](https://tickets.puppetlabs.com/browse/CDPE-2085)
* [CDPE-2086](https://tickets.puppetlabs.com/browse/CDPE-2086)
* [CDPE-2087](https://tickets.puppetlabs.com/browse/CDPE-2087)
* [CDPE-2087](https://tickets.puppetlabs.com/browse/CDPE-2088)


### Manual
[Docs](https://puppet.com/docs/continuous-delivery/2.x/start_deploying.html#task-3794)

_Setup_:
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories`
* Click on appropriate control repo

_DOCS_:
* [CDPE-2089](https://tickets.puppetlabs.com/browse/CDPE-2089)

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify New Deployment button | 1. Click New Deployment button | Modal should appear with branch associated with pipeline selected and commit selection open | |
| Verify commit selection | 1. Successfully perform 'Verify New Deployment button' test <BR> 2. Select commit in 'Select a commit' list | 'Select Puppet Enterprise instance' selection should appear with a default selection <BR> 'Select a node group' selection should appear | [CDPE-2090](https://tickets.puppetlabs.com/browse/CDPE-2090) |
| Verify node group selection | 1. Successfully perform 'Verify commit selection' test <BR> 2. Select 'All testing' node group in 'Select a node group' list | 'Select a deployment policy' selection should appear | [CDPE-2091](https://tickets.puppetlabs.com/browse/CDPE-2091) |
| Verify deployment policy help | 1. Successfully perform 'Verify node group selection' test <BR> 2. Click 'Help me choose' link in 'Select a deployment policy' header | Deployment Policy document should be opened in another browser tab | |
| Verify Direct Deployment policy selection | 1. Successfully perform 'Verify node group selection' test <BR> 2. Select  'Direct Deployment Policy' in 'Select a deployment policy' list | Policy settings should appear <BR>  All settings _except_ timeout should be disabled <BR> Description field should appear | |
| Verify Timeout field (direct deployment) - minimum (1)  | 1. Successfully perform 'Verify Direct Deployment policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2092](https://tickets.puppetlabs.com/browse/CDPE-2092) |
| Verify Timeout field (direct deployment) - maximum (1440)  | 1. Successfully perform 'Verify Direct Deployment policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter '2000' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2093](https://tickets.puppetlabs.com/browse/CDPE-2093) |
| Verify Timeout field (direct deployment) - numeric | 1. Successfully perform 'Verify Direct Deployment policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate Conditions toggle (direct deployment) | 1. Successfully perform 'Verify Direct Deployment policy selection' test <BR>  2. Click the 'Abort deployment if' box | Toggle should turn green and node count field should be enabled  | |
| Verify Terminate nodes field (direct deployment) - minimum (1)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2094](https://tickets.puppetlabs.com/browse/CDPE-2094) |
| Verify Terminate nodes field (direct deployment) - maximum (?)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeds the allowed maximum in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2095](https://tickets.puppetlabs.com/browse/CDPE-2095) |
| Verify Terminate nodes field (direct deployment) - numeric | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify No-op toggle (direct deployment) | 1. Successfully perform 'Verify Direct Deployment policy selection' test <BR>  2. Click the 'Run this deployment in no-op mode' box | Toggle should turn green | |
| Verify direct deployment | 1. Successfully perform 'Verify Direct Deployment policy selection' test  <BR>  3. Enter 'test deploy' in the Description field  4. Click 'Deploy' button | Deploy should be successfully submitted | |
| Verify Eventual Consistency policy selection | 1. Successfully perform 'Verify node group selection' test <BR>  2. Select 'Eventual Consistency Policy' in 'Select a deployment policy' list | Description field should appear | |
| Verify eventual consistency deployment | 1. Successfully perform 'Verify Eventual Consistency policy selection' test  <BR>  3. Enter 'test deploy' in the Description field  4. Click 'Deploy' button | Deploy should be successfully submitted | |
| Verify Temporary Branch policy selection | 1. Successfully perform 'Verify node group selection' test <BR> 2. Select  'Temporary Branch Policy' in 'Select a deployment policy' list | Policy settings should appear <BR>  All settings _except_ timeout and stagger should be disabled <BR> Description field should appear | |
| Verify Timeout field (temp branch) - minimum (1)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2092](https://tickets.puppetlabs.com/browse/CDPE-2092) |
| Verify Timeout field (temp branch) - maximum (1440)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter '2000' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2093](https://tickets.puppetlabs.com/browse/CDPE-2093) |
| Verify Timeout field (temp branch) - numeric | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (temp branch) - minimum (1)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (temp branch) - maximum (?)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2096](https://tickets.puppetlabs.com/browse/CDPE-2096) |
| Verify stagger nodes field (temp branch) - numeric | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (temp branch) - minimum (1)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (temp branch) - maximum (?)  | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2097](https://tickets.puppetlabs.com/browse/CDPE-2097) |
| Verify stagger delay field (temp branch) - numeric | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate Conditions toggle (temp branch) | 1. Successfully perform 'Verify Temporary Branch policy selection' test <BR>  2. Click the 'Abort deployment if' box | Toggle should turn green and node count field should be enabled  | |
| Verify Terminate nodes field (temp branch) - minimum (1)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2094](https://tickets.puppetlabs.com/browse/CDPE-2094) |
| Verify Terminate nodes field (temp branch) - maximum (?)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeds the allowed maximum in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2095](https://tickets.puppetlabs.com/browse/CDPE-2095) |
| Verify Terminate nodes field (temp branch) - numeric | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify No-op toggle (temp branch) | 1. Successfully perform 'Verify Temporary Branch policy selection' test <BR>  2. Click the 'Run this deployment in no-op mode' box | Toggle should turn green | |
| Verify temporary branch deployment | 1. Successfully perform 'Verify Temporary Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field  4. Click 'Deploy' button | Deploy should be successfully submitted | |
| Verify Incremental Branch policy selection | 1. Successfully perform 'Verify node group selection' test <BR> 2. Select  'Incremental Branch Policy' in 'Select a deployment policy' list | Policy settings should appear <BR>  All settings _except_ timeout and stagger should be disabled <BR> Description field should appear | |
| Verify Timeout field (incr branch) - minimum (1)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2092](https://tickets.puppetlabs.com/browse/CDPE-2092) |
| Verify Timeout field (incr branch) - maximum (1440)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter '2000' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2093](https://tickets.puppetlabs.com/browse/CDPE-2093) |
| Verify Timeout field (incr branch) - numeric | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (incr branch) - minimum (1)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (incr branch) - maximum (?)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2096](https://tickets.puppetlabs.com/browse/CDPE-2096) |
| Verify stagger nodes field (incr branch) - numeric | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (incr branch) - minimum (1)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (incr branch) - maximum (?)  | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2097](https://tickets.puppetlabs.com/browse/CDPE-2097) |
| Verify stagger delay field (incr branch) - numeric | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate Conditions toggle (incr branch) | 1. Successfully perform 'Verify Incremental Branch policy selection' test <BR>  2. Click the 'Abort deployment if' box | Toggle should turn green and node count field should be enabled  | |
| Verify Terminate nodes field (incr branch) - minimum (1)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2094](https://tickets.puppetlabs.com/browse/CDPE-2094) |
| Verify Terminate nodes field (incr branch) - maximum (?)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeds the allowed maximum in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2095](https://tickets.puppetlabs.com/browse/CDPE-2095) |
| Verify Terminate nodes field (incr branch) - numeric | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify No-op toggle (incr branch) | 1. Successfully perform 'Verify Incremental Branch policy selection' test <BR>  2. Click the 'Run this deployment in no-op mode' box | Toggle should turn green | |
| Verify incremental branch deployment | 1. Successfully perform 'Verify Incremental Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field  4. Click 'Deploy' button | Deploy should be successfully submitted | |
| Verify Blue Green Branch policy selection | 1. Successfully perform 'Verify node group selection' test <BR> 2. Select  'Blue Green Branch Policy' in 'Select a deployment policy' list | Policy settings should appear <BR>  All settings _except_ timeout and stagger should be disabled <BR> Description field should appear | |
| Verify Timeout field (blue/green branch) - minimum (1)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2092](https://tickets.puppetlabs.com/browse/CDPE-2092) |
| Verify Timeout field (blue/green branch) - maximum (1440)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter '2000' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2093](https://tickets.puppetlabs.com/browse/CDPE-2093) |
| Verify Timeout field (blue/green branch) - numeric | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (blue/green branch) - minimum (1)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger nodes field (blue/green branch) - maximum (?)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2096](https://tickets.puppetlabs.com/browse/CDPE-2096) |
| Verify stagger nodes field (blue/green branch) - numeric | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger nodes field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (blue/green branch) - minimum (1)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify stagger delay field (blue/green branch) - maximum (?)  | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeded the allowed maximum in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2097](https://tickets.puppetlabs.com/browse/CDPE-2097) |
| Verify stagger delay field (blue/green branch) - numeric | 1. Successfully perform 'Verify Blue Green Branch policy selection' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter 'hello' in the contents of the stagger delay field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | |
| Verify Terminate Conditions toggle (blue/green branch) | 1. Successfully perform 'Verify Blue Green Branch policy selection' test <BR>  2. Click the 'Abort deployment if' box | Toggle should turn green and node count field should be enabled  | |
| Verify Terminate nodes field (blue/green branch) - minimum (1)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Delete the contents of the node count field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2094](https://tickets.puppetlabs.com/browse/CDPE-2094) |
| Verify Terminate nodes field (blue/green branch) - maximum (?)  | 1. Successfully perform 'Verify Terminate Conditions toggle' test  <BR>  3. Enter 'test deploy' in the Description field <BR>  4. Enter a number that exceeds the allowed maximum in the contents of the timeout field  <BR> 5. Click 'Deploy' button | Deploy button should be grayed out or unavailable | [CDPE-2095](https://tickets.puppetlabs.com/browse/CDPE-2095) |
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
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories`
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
| Verify puppetfile-syntax-validate job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<workspace>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Validate that a control repo's Puppetfile is syntactically correct/ | |


##### Control Repo Template Syntax Validate
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify template-syntax-validate job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'control-repo-template-syntax-validate' should be present in the 'Select Job' list | |
| Verify Add template-syntax-validate job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'control-repo-template-syntax-validate' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'control-repo-template-syntax-validate' job should appear as Pipeline stage | |
| Verify template-syntax-validate job trigger - success | 1. Add and commit a change to the control repo master branch adding a comment to a template <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify template-syntax-validate job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates a template <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify template-syntax-validate job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify template-syntax-validate job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<workspace>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Validate that a control repo's templates are syntactically correct/ | |


##### Control Repo Hiera Syntax Validate
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify hiera-syntax-validate job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'control-repo-hiera-syntax-validate' should be present in the 'Select Job' list | |
| Verify Add hiera-syntax-validate job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'control-repo-hiera-syntax-validate' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'control-repo-hiera-syntax-validate' job should appear as Pipeline stage | |
| Verify hiera-syntax-validate job trigger - success | 1. Add and commit a change to the control repo master branch adding a comment to the hiera data <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify hiera-syntax-validate job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates the hiera data <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify hiera-syntax-validate job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify hiera-syntax-validate job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<workspace>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Validate that a control repo's Hiera data is syntactically correct/ | |


##### Control Repo Puppet Manifest Syntax Validate
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify manifest-syntax-validate job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'control-repo-manifest-syntax-validate' should be present in the 'Select Job' list | |
| Verify Add manifest-syntax-validate job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'control-repo-manifest-syntax-validate' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'control-repo-manifest-syntax-validate' job should appear as Pipeline stage | |
| Verify manifest-syntax-validate job trigger - success | 1. Add and commit a change to the control repo master branch adding a comment to a manifest <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify manifest-syntax-validate job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates a manifest <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify manifest-syntax-validate job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify manifest-syntax-validate job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<workspace>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Validate that a control repo's Puppet manifest code is syntactically correct/ | |


##### Module PDK Validate
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify pdk-validate job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'module-pdk-validate' should be present in the 'Select Job' list | |
| Verify Add pdk-validate job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'module-pdk-validate' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'module-pdk-validate' job should appear as Pipeline stage | |
| Verify pdk-validate job trigger - success | 1. Add and commit a change the module master branch adding a comment to a manifest <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify pdk-validate job trigger - failure | 1. Add and commit a change to the module master branch that invalidates a manifest <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify pdk-validate job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify pdk-validate job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<workspace>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Validate that a module's Puppet manifest code is syntactically correct/ | |


##### Run Module Unit Test
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify rspec-puppet job present | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) | 'module-rspec-puppet' should be present in the 'Select Job' list | |
| Verify Add rspec-puppet job | 1. Successfully perform 'Verify Add stage job' test [Pipelines: Create Stage](#create-stage) <BR>  2. Select 'module-rspec-puppet' job from the 'Select Job' list <BR>  3. Click Add Stage button <BR>  4. Click 'Done' button | The 'module-rspec-puppet' job should appear as Pipeline stage | |
| Verify rspec-puppet job trigger - success | 1. Add and commit a change to the module master branch adding a comment to an rspec test <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify rspec-puppet job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates an rspec test <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify rspec-puppet job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify rspec-puppet job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<workspace>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Running .\* -m Run rspec-puppet unit tests on a module/ | |


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
| Verify custom job trigger - success | 1. Add and commit a change to the control-repo master branch adding a comment to manifests/site.pp <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | |
| Verify custom job trigger - failure | 1. Add and commit a change to the control repo master branch that invalidates manifests/site.pp ("// Bad comment") <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A job failed notice | |
| Verify custom job event pipeline detail | 1. Successfully complete 'Verify job trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Push webhook | |
| Verify custom job details | 1. Successfully complete 'Verify job event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<workspace>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. <BR> - The log should match /Puppet-lint validation on the Control Repo has/ | [CDPE-2098](https://tickets.puppetlabs.com/browse/CDPE-2098), [CDPE-2099](https://tickets.puppetlabs.com/browse/CDPE-2099) |


#### Deploy
_Setup_:
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories`
* Click on appropriate control repo
* Click on master branch
* Create pipeline with deploy stage:
  1. Successfully perform 'Verify Add stage deployment' test from the [Pipelines: Create Stage](#create-stage) section above on the master pipeline.
  1. Select the 'testing' node group
  1. Select the 'Direct Deployment Policy' deployment policy
  1. Click 'Add Stage'

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify commit hook event | 1. Add and commit a change to the control repo master branch <BR>  2. Push the change, if necessary, to the git server <BR>  3. Wait 5 seconds | The 'New Events' button should appear on the `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories/<control-repo>` page | |
| Verify deployment trigger | 1. Successfully complete 'Verify commit hook event' test <BR>  2. Click the 'New Events' button | An event for the deployment should appear at the top of the event list.  It should include: <BR> - `master @ <SHA>` where the SHA matches that of the commit. <BR> - A deployment succeeded notice | |
| Verify deploy event pipeline detail | 1. Successfully complete 'Verify deployment trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the deployment run <BR> - A Push webhook | |
| Verify deploy details | 1. Successfully complete 'Verify deploy event pipeline detail' test <BR>  2. Click the link to the deploy number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<workspace>/deployments/<deploy-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `master @ <SHA>` where the SHA matches the commit that triggered the deploy. <BR> - Update Ref: A commit push to the testing branch <BR> - Code deploy: Indicating the testing environment <BR> - Rolling Deployment: A link to the PE job running puppet on the nodes classified for the testing environment <BR> - Cleanup | _UX_: If puppet run completes with failures, the color of the 'Puppet Run Jobs' should not be green. |


#### Pull Request
_Setup_:
* Perform [Code Deploy::Pipelines::Job](#pipeline-job) setup.
* Enable Pull Request trigger on pipeline
  1. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories/<control-repo>`
  1. Click 'Pipeline Settings' for master pipeline (tool icon)
  1. Enable 'Pull Request' trigger (_UX_: Label 'Pull Request' with space)
  1. Click 'Save Settings' button
  1. Click 'Done' button
* Create `foobar` branch on the control repo


|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify pull request hook event | 1. Add and commit a change to the control repo foobar branch <BR>  2. Push the change, if necessary, to the git server <BR>  3. Open a request to merge changes from foobar branch to master branch <BR>  4. Wait 5 seconds | The 'New Events' button should appear on the `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories/<control-repo>` page | |
| Verify pull request trigger - success | 1. Successfully complete 'Verify pull request hook event' test <BR>  2. Click the 'New Events' button | An event for the PR should appear at the top of the event list.  It should include: <BR> - `foobar @ <SHA>` where the SHA matches that of the commit. <BR> - A job succeeded notice | [CDPE-2100](https://tickets.puppetlabs.com/browse/CDPE-2100),  [CDPE-2101](https://tickets.puppetlabs.com/browse/CDPE-2101) |
| Verify pull request event pipeline detail | 1. Successfully complete 'Verify pull request trigger - success' test <BR>  2. Click the 'Succeeded' link in the event | The event details should appear with the following: <BR> - A link to the job run <BR> - a 'Rerun Job' button <BR> - A Pull Request webhook | |
| Verify pull request job details | 1. Successfully complete 'Verify pull request event pipeline detail' test <BR>  2. Click the link to the job number | The job page should load `http://<cd4pe-instance>:<web-ui-port>/<workspace>/jobs/<job-number>`.  It should include: <BR> - The completed status of the job. <BR> - Commit `foobar @ <SHA>` where the SHA matches the commit that triggered the job. <BR> - A log of the distelli build for the job. | |
| Verify pull request VCS integration | 1. Successfully complete 'Verify pull request hook event' test <BR>  2. Open the VCS UI for the pull request opened | An entry for the pipeline should appear.  It should include: <BR> - A link to the event for the run of the pipeline stage | |


### Approval
[Docs](https://puppet.com/docs/continuous-delivery/2.x/approval.html)

_Setup_:
* Perform [add job hardware](#add_job_hardware) setup.
* Perform [code deploy](#code-deploy) setup.

#### Create Group
_Setup_:
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/settings/groups`

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify Add Group link | 1. Click '+Create Group' link | 'Create Group' modal should appear | _UX_: Link should be '+Add Group' to be consistent |
| Verify Group Name field - minimum (1)  | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Create Group button | Group creation should fail, reporting that the field must be populated | |
| Verify Group Name field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Create Group button | Group creation should fail, reporting maximum acceptable length | [CDPE-2102](https://tickets.puppetlabs.com/browse/CDPE-2102) |
| Verify Group Name field - invalid character set  | 1. Fill field with 'ༀ-%© foo' <BR> 2. Fill in other fields <BR> 3. Click Install button | Group creation should fail, reporting acceptable character set | |
| Verify Group Name field - valid character set  | 1. Fill field with '-_-_foo' <BR> 2. Fill in other fields <BR> 3. Click Install button | Group creation should succeed and group should be accessible in group list | [CDPE-2103](https://tickets.puppetlabs.com/browse/CDPE-2103) |
| Verify Group Description field - minimum (1)  | 1. Leave field blank <BR> 2. Fill in other fields <BR> 3. Click Create Group button | Group creation should fail, reporting that the field must be populated | |
| Verify Group Description field - maximum (?)  | 1. Fill field with string exceeding maximum <BR> 2. Fill in other fields <BR> 3. Click Create Group button | Group creation should fail, reporting maximum acceptable length | |
| Verify Group Description field - utf-8 character set  | 1. Fill field with 'ༀ-%© foo' <BR> 2. Fill in other fields <BR> 3. Click Install button | Group creation should succeed and group should be accessible in group list | |
| Verify delete group | 1. Successfully perform 'Verify Group Name field - valid character set' test <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/settings/groups` <BR> 3. Click trash-can icon for group | Deletion confirmation modal should appear | |
| Verify delete group button | 1. Successfully perform 'Verify delete group' test <BR> 2. Click Remove button | Group should be absent from list | [CDPE-2105](https://tickets.puppetlabs.com/browse/CDPE-2105) |
| Verify no groups | 1. Delete all groups | Group list should be empty | |
| Verify group details button | 1. Successfully perform 'Verify Group Name field - valid character set' test <BR> 2. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/settings/groups` <BR> 3. Click view details icon for group | Group details modal should appear | |
| Verify permissions | 1. Successfully perform 'Verify group details button' test <BR> 2. Click '+Set Permissions' for control repos <BR> 3. Check List <BR>  4. Click Set Permissions button for control repos | 'List' should appear in the permissions for control repos | _UX_: Should there be a single Set Permissions button for this modal that saves all selections rather than individual buttons per section?  Should all sections be expanded? |
| Verify group members | 1. Successfully perform 'Verify group details button' test <BR> 2. Click '+Add Members' <BR> 3. Select user <BR>  4. Click Add Members button for control repos | User should appear in group member list | [CDPE-1994](https://tickets.puppetlabs.com/browse/CDPE-1994) |


#### Manage Protected Environment
_Setup_:
* [Create approval group](#create-group)
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/settings/puppet-enterprise`

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify protected environments link | 1. Click numeric link under protected environments column for PE classifier under test | 'Puppet Enterprise Protected Environments' modal should appear | |
| Verify no environments cancel button | 1. Successfully perform 'Verify protected environments link' test <BR> 2. Click Cancel button | 'Puppet Enterprise Protected Environments' modal should close and return user to the PE settings page | |
| Verify no environments add button | 1. Successfully perform 'Verify protected environments link' test <BR> 2. Click Add button | Select Puppet environment should appear with list of environments | |
| Verify puppet environment selection - minimum (1)  | 1. Successfully perform 'Verify no environments add button' test <BR> 2. Leave field blank <BR> 3. Fill in other fields <BR> 4. Click Add button | Protected environment creation should fail, reporting that the field must be populated | |
| Verify approval group selection - minimum (1)  | 1. Successfully perform 'Verify no environments add button' test <BR>  2. Leave field blank <BR> 3. Fill in other fields <BR> 4. Click Add button | Protected environment creation should fail, reporting that the field must be populated | |
| Verify add protected environment | 1. Successfully perform 'Verify no environments add button' test <BR> 2. Select Puppet environment <BR> 3. Enable approval group <BR> 4. Click Add button | Protected environment creation should succeed and the number of protected environments for the PE integration should be incremented | [CDPE-2104](https://tickets.puppetlabs.com/browse/CDPE-2104) |


#### Approval Workflow
_Setup_:
* [Create approval group](#create-group)
* [Create protected environment](#manage-protected-environment)
* [Create pipeline with deployment stage to the protected environment](#deploy)
* [Manually trigger pipeline](#manual)

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify deploy pending approval | 1. Expand events associated with pipeline run | Deployment stage should have status: 'Deployment Pending Approval' | |
| Verify approval notice in message center  | 1. Navigate to `http://<cd4pe-instance>:<web-ui-port>/<user>/messages` | Message should be listed for pipeline run with a link to provide approval | |
| Verify approve deployment run | 1. Successfully perform 'Verify approval notice in message' test <BR> 2. Click on approval link | Deployment run should appear with a 'pending approval' status and a button to provide approval | |
| Verify approve deployment modal | 1. Successfully perform 'Verify approval deployment run' test <BR> 2. Click on provide approval button | 'Provide Approval Decision' modal should appear | |
| Verify decline approve deployment | 1. Successfully perform 'Verify approval deployment modal' test <BR> 2. Click on deny button | Deployment run should appear with a 'declined' status and NOT execute the code deploy | |
| Verify approve deployment | 1. Successfully perform 'Verify approval deployment modal' test <BR> 2. Click on approve button | Deployment run should appear with an 'approved' status and execute the code deploy | |


## Impact Analysis
[Doc](https://puppet.com/docs/continuous-delivery/2.x/impact_analysis.html)

_Setup_:
* [Install CD4PE](#installation)
* [Integrate with GitLab](#gitlab)
* [Integrate with PE](#pe-integration)
* Create topic branch
* Add pipeline for topic branch
* Add direct deployment stage for each node group to pipeline. (Enhancement: Add a shortcut for this.)
* Add impact analysis stage to pipeline
* Reorder stages putting impact analysis on top. (UX: Remove the constraint that a deploy step must be added first)
* Modify `manifests/site.pp` on topic branch
```
node default {
  file { '/tmp/foo':
    ensure => directory,
  }
  tidy { '/tmp/foo':
    recurse => true,
    backup  => false
  }
  file { '/tmp/foo/test.txt':
    content => 'Foo me once, shame on foo!'
  }
}
```
* Navigate to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/repositories/<control-repo>`

### New Impact Analysis Button
|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify New Impact Analysis Button | 1. Click New Impact Analysis button | 'New Impact Analysis' modal should appear with 'Select a branch' selection available | |
| Verify branch selection | 1. Successfully perform 'Verify New Impact Analysis Button' test <BR> 2. Select topic branch from the 'Select a branch' list | 'Select a commit' should appear | |
| Verify commit selection | 1. Successfully perform 'Verify branch selection' test <BR> 2. Select latest commit from the 'Select a commit' list | 'Select Puppet Enterprise instance' should appear | |
| Verify PE instance selection | 1. Successfully perform 'Verify commit selection' test <BR> 2. Select PE instance in 'Select Puppet Enterprise instance' list | 'Select a node group' selection should appear |  _UX_: Selection names are not internally consistent |
| Verify node group selection | 1. Successfully perform 'Verify PE instance selection' test <BR> 2. Select 'All testing' node group in 'Select a node group' list | Concurrent node catalog selection should appear | |
| Verify concurrent node catalogs - minimum (1)  | 1. Successfully perform 'Verify node group selection' test  <BR>  2. Delete the contents of the concurrent node catalog field  <BR> 3. Click 'Analyze' button | Analyze button should be grayed out or unavailable | |
| Verify concurrent node catalogs - maximum (?)  | 1. Successfully perform 'Verify node group selection' test  <BR>  2. Enter a number that exceeds the allowed maximum in the concurrent node catalog field  <BR> 3. Click 'Analyze' button | Analyze button should be grayed out or unavailable | [CDPE-2107](https://tickets.puppetlabs.com/browse/CDPE-2107) |
| Verify concurrent node catalogs - non-numeric  | 1. Successfully perform 'Verify node group selection' test  <BR>  2. Enter 'hello' in the concurrent node catalog field  <BR> 3. Click 'Analyze' button | Analyze button should be grayed out or unavailable | [CDPE-2106](https://tickets.puppetlabs.com/browse/CDPE-2106) |
| Verify concurrent node catalogs - numeric  | 1. Successfully perform 'Verify node group selection' test  <BR>  2. Enter '5' in the concurrent node catalog field  <BR> 3. Click 'Analyze' button | 1. 'Impact analysis in progress' should be displayed <BR> 2. 'View Impact Analysis' button should be displayed | |
| Verify View Impact Analysis button | 1. Successfully perform 'Verify concurrent node catalogs - numeric' test <BR> 2. Click 'View Impact Analysis' button |  Browser should be directed to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/analysis/<number>` where run number corresponds to the run created (see [Run Results](#impact-analysis-run-results) test section)|  |


### Impact Analysis Run Results
_Setup_: Successfully perform 'Verify View Impact Analysis button' test.

|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify run results elements | None. | Page should contain: <BR> 1. Link to branch associated with analysis run <BR> 2. Link to commit associated with analysis run <BR> 3. Name of PE server associated with analysis run <BR> 4. Environment associated with analysis run <BR> 5. Number of resource changes in environment  <BR> 6. Number of impacted nodes in environment <BR> 7. Link to change details | |
| Verify change details - resource view | Click View changes link for environment associated with analysis run | Page should appear with changes defaulted to resources view. This view should contain a list of resources.  For each resource, the number of parameters changed for each resource should be listed.  If there is only a single changed parameter, its current and new values should be listed.  For each resource, the number of impacted nodes should be listed and this number should link to a detailed view. | |
| Verify resource change details - resource view | 1. Click View changes link for environment associated with analysis run <BR> 2. For a resource, click on number of impacted nodes  | A modal containing details for the resource should appear with resource view defaulted.  This view should contain: <BR> 1. The number of impacted nodes <BR> 2. Each parameter with its: Current value, new value, and status.  | |
| Verify resource change details - impacted nodes view | 1. Click View changes link for environment associated with analysis run <BR> 2. For a resource, click on number of impacted nodes <BR> 3. Click impacted nodes view radio button | A list of certnames for impacted nodes should appear. | |
| Verify change details - nodes view | 1. Click View changes link for environment associated with analysis run <BR> 2. Click Nodes view radio button | This view should contain a list of nodes impacted.  For each node, the certname, summary of impacted resources, compile status, and link to detailed view should be listed. | |
| Verify impacted node detail | 1. Click View changes link for environment associated with analysis run <BR> 2. Click Nodes view radio button  <BR> 3. Click 'View details' link for an impacted node | A modal containing details for the resources impacted for the specific node should appear. For each resource, the name, all changed parameters with current and new values, as well as status should be listed. | |


### Impact Analysis As Part of Pipeline Run
_Setup_:
* Click Run Pipeline Button
* Select pipeline
* Select commit
* Click Trigger Pipeline button
  * Pipeline should be successfully triggered
* Click Done
* Refresh the page to see new events.


|  Test Name | Steps  |  Expected Result |  Notes |
| :--------- | :----- | :--------------- | :----- |
| Verify impact analysis in pipeline events | 1. Click on the most recent event number | The pipeline stage should be revealed and should include the impact analysis logo, a match to /Impact Analysis[Running\|Done], and a link to the analysis run | |
| Verify impact analysis run link in pipeline events | 1. Successfully complete 'Verify impact analysis in pipeline events' test <BR> 2. Click impact analysis run number | Browser should be directed to `http://<cd4pe-instance>:<web-ui-port>/<workspace>/analysis/<number>` where run number corresponds to the run created (see [Run Results](#impact-analysis-run-results) test section)| |

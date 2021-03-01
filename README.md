# aws-terraform-cicd-java-springboot
Terraform: AWS CICD with CodePipeline, CodeBuild and ECS and a Springboot App

## Java Resources
- [spring-testing-separate-data-source](https://www.baeldung.com/spring-testing-separate-data-source) and [github](https://github.com/eugenp/tutorials/tree/master/persistence-modules/spring-boot-persistence)
- [testing-with-configuration-classes-and-profiles](https://spring.io/blog/2011/06/21/spring-3-1-m2-testing-with-configuration-classes-and-profiles)
- [hibernate-ddl-auto-example](https://www.onlinetutorialspoint.com/hibernate/hbm2ddl-auto-example-hibernate-xml-config.html)
- [cleaning-up-spring-boot-integration-tests-logs](https://ricardolsmendes.medium.com/cleaning-up-spring-boot-integration-tests-logs-5b2d0a5f29bc)
- [docker-caching-strategies](https://testdriven.io/blog/faster-ci-builds-with-docker-cache/)

## Run Locally

```
$ docker-compose up --build
```

Make a request to view all cars:

```
$ curl http://localhost:8080/api/cars
[]
```

Create one car:

```
$ curl -H "Content-Type: application/json" http://localhost:8080/api/cars -d '{"make":"bmw", "model": "m3"}'
{"id":3,"make":"bmw","model":"m3","createdAt":"2021-03-01T14:12:07.624+00:00","updatedAt":"2021-03-01T14:12:07.624+00:00"}
```

View all cars again:

```
$ curl http://localhost:8080/api/cars
[{"id":3,"make":"bmw","model":"m3","createdAt":"2021-03-01T14:12:08.000+00:00","updatedAt":"2021-03-01T14:12:08.000+00:00"}]
```

View a specific car:

```
$ curl http://localhost:8080/api/cars/3
{"id":3,"make":"bmw","model":"m3","createdAt":"2021-03-01T14:12:08.000+00:00","updatedAt":"2021-03-01T14:12:08.000+00:00"}
```

Delete a car:

```
$ curl -XDELETE http://localhost:8080/api/cars/3
```

View application status:

```
$ curl -s http://localhost:8080/status | jq .
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "MySQL",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 62725623808,
        "free": 2183278592,
        "threshold": 10485760,
        "exists": true
      }
    },
    "ping": {
      "status": "UP"
    }
  }
}
```

Or the database status individually:

```
$ curl -s http://localhost:8080/status/db
{"status":"UP","details":{"database":"MySQL","validationQuery":"isValid()"}}
```

## Credit

Huge thanks to [this post](https://www.callicoder.com/spring-boot-rest-api-tutorial-with-mysql-jpa-hibernate/) for the rest api example which this example is based off.
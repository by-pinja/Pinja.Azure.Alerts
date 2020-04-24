# Fixing web app

Follow resource link from alert (resource is likely different than in image):


## Restarting web app

In resource Overview (from left) at top overview page there is restart button:

![Restart button](img/2020-04-24-08-19-41.png)

Press it and  approve restart.

![Apply](./img/2020-04-24-08-19-56.png)

Wait for 5 minutes to make sure restart is ready. After that validate that is application working.

## Checking service status of web application

Check alerting service health:

![Service health button](./img/2020-04-24-09-22-43.png)

And follow tutorial from <https://docs.microsoft.com/en-us/azure/service-health/resource-health-overview>

## Checking Azure service status

Broad scope problems <https://status.azure.com/en-gb/status>, however only issues affecting hole region is visible here.

For more specific status from <https://portal.azure.com/#blade/Microsoft_Azure_Health/AzureHealthBrowseBlade/serviceIssues>

## Changing scale of application / full restart

This enforces full restart of application plan. It is good to know that this will affect all applications running on same plan so only do this if issue is major.

Navigate to Scale Up

![Scale up](./img/2020-04-24-08-23-32.png)

There you can see current plan, change it to 1 tier upwards.

![TiersA](./img/2020-04-24-08-20-25.png)

![TiersB](./img/2020-04-24-08-20-45.png)

After that press 

![Apply](./img/2020-04-24-08-21-04.png)

Scaling will take little while. Wait for 15 minutes and check if issue is fixed.

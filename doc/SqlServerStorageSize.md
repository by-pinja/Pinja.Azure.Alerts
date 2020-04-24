# SQL Server storage size

Go to alerting resource from link:

![Affected resource link](img/2020-04-22-11-39-41.png)

Select Overview if not selected as default:

![Overview](img/2020-04-24-07-58-22.png)

Check that database is really getting full, in this picture empty test database is shown:

![Db usage](img/2020-04-24-07-58-46.png)

Scaling size
In Overview tab there is button to go pricing tier (tier is likely different than in image):

![Pricing tier](img/2020-04-24-07-58-59.png)

In that page there is slider to increase database size:

![SliderA](img/2020-04-24-08-01-16.png)

Move it one step further right (exact values may differ):

![SliderB](img/2020-04-24-08-01-47.png)

Then press apply:

![Apply](img/2020-04-24-08-02-03.png)

Scaling might take a moment, however it should be transparent to end users.
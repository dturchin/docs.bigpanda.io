---
layout: integration 
title: "New Relic"
draft: true

---
#### Locate Alert Policies Settings
In the *New Relic* dashboard, navigate to [Tools > Alert Policies > Channels and groups](https://rpm.newrelic.com/notification_channels)

<!-- section-separator -->

#### Create Channel for BigPanda
Click on `Create channel` and select `Webhook`. Fill in the form:

* **Webhook Name**: `BigPanda`
* **Webhook URL**: `https://api.bigpanda.io/data/integrations/newrelic?access_token=$TOKEN`
* **Notification level**: `All critical events`

Click on `Integrate with Webhooks`.

<!-- section-separator -->

#### Apply Webhook to All Policies

* Navigate to [Account settings > Integrations > Data sharing](https://rpm.newrelic.com/integrations?page=data_sharing)
* If API access is not already enabled, click on `Enable API access`.
<!-- include-start -->
* Copy the `API key` to the form below.

<!-- include 'integrations/newrelic/newrelic' -->
<!-- include-end -->
<!-- include-replace-start -->

In the BigPanda Application, there's a Form that you can enter you API, which will create the New Relic WebHook for you.

<!-- include-replace-end -->

<!-- section-separator -->

#### Test the webhook

* Go back to [Channels and groups](https://rpm.newrelic.com/notification_channels)
* Navigate to `Channels > Webhook > BigPanda`, 
* Click on the `send test message` link.

You should now be able to see a test incident in the **OpsBox** screen.

_**Note:** BigPanda will automatically close the test incident after 3 hours, make sure you can see the alert in the **OpsBox** screen._

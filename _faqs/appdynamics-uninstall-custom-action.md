---
layout: page
title: "How can i uninstall BigPanda custom action from AppDynamics?"
---

This tutorial will walk you through removing the BigPanda custom action from AppDynamics:

* For every application you have configured in AppDynamics, go to `Application > Alert & Respond > Policies` and remove the `BigPanda` policy.
* For every application you have configured in AppDynamics, go to `Application > Alert & Respond > Actions` and remove the `BigPandaAlert` custom action.
* Edit `<CONTROLLER INSTALL ROOT>/custom/actions/custom.xml` and remove these lines:

          <action>
              <type>bigpanda-alert</type>
              <executable>bigpanda_alert.py</executable>
          </action>

* Remove the `<CONTROLLER INSTALL ROOT>/custom/actions/bigpanda-alert` directory.

__Note__: `bigpanda-alert` will remain in the custom actions drop down until the next custom actions reload.


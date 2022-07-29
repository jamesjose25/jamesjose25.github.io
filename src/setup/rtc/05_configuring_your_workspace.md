# Configuring your RTC workspace

If you are intending to develop and deliver changes to the product, it is important that you keep up with the _head of stream_ to ensure your changes don't clash with work other people are doing. The easiest way to do this is to change the _Flow Targets_ on your workspace and its components so that they point to the right streams in RTC. Set the following targets for the workspace and its components by right clicking the relevant part in the _Pending Changes_ tab of RTC:

* A v10 workspace should flow against the `IB1000` stream, and the individual components should each have the following targets:

   Workspace component | Flow target
   ---|---
   IB Server Build PreReqs | IB1000 Build PreReqs
   IB Server Core | IB1000 Server
   IB Webui | IB1000 Web UI
   IB_Messages | IB1000 Messages
   ibpackaging | IB1000
   Integration_API | IB1000 Integration API
   Version | IB1000 Version

* A v11 workspace should flow against the `IB1100` stream, and the individual components should each have the following targets:

   Workspace component | Flow target
   ---|---
   config_schema | IB1100 Server
   IB Server Build PreReqs | IB1100 Server
   IB Server Core | IB1100 Server
   IB_Messages | IB1100 Server
   ibpackaging | IB1100
   Integration_API | IB1100 Server
   Version | IB1100 Server

* A vNext workspace should flow against the `ib000` stream, and the individual components should each have the following targets:

    Workspace component | Flow target
   ---|---
   config_schema | IB Server Core Dev
   IB Server Build PreReqs | IB Server Core Dev
   IB Server Core | IB Server Core Dev
   IB_Messages | IB Server Core Dev
   ibpackaging | ib000
   Integration_API | IB Server Core Dev
   Version | IB Server Core Dev
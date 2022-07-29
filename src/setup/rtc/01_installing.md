
# Installing Eclipse and the RTC client

The RTC client is an Eclipse plugin, so you will need a copy of Eclipse to install this into. Since the ACE toolkit is an Eclipse application, you can install it directly into there. I prefer to install it into a clean Eclipse instance. The RTC plugin is only compatible with Eclipse 2020-06 and older, these instructions will guide you through installing this back level version of Eclipse.

Before continuing make sure you have installed an IBM Java 8 SDK as described in the [Prerequisite software](../prereqs/index.md) section for your platform.

## Installing Eclipse 2020-06

1. Go to the [Eclipse Installer Download page](https://www.eclipse.org/downloads/packages/installer) to download and then run the Eclipse Installer.
1. Click the _hamburger_ menu icon in the top right of the Eclipse Installer to open up the side menu
   ![Screenshot showing Eclipse installer side menu](images/eclipse_installer_01.png)
1. From the side menu, click _Advanced Mode..._ to bring up the Advanced Mode window. Select _Eclipse IDE for Java Developers_ and change the _Product Version_ to `2020-06`.
   ![Screenshot showing Eclipse installer advanced mode](images/eclipse_installer_02.png)
1. Click the _Manage virtual machines..._ icon next to the _Java 1.8+ VM_ drop down box, circled in the above image. Click the _Browse_ button and navigate to your IBM Java 8 SDK installation. The folder you choose should contain the `bin` and `jre` folders which make up your Java SDK.
   ![Screenshot showing correct Java folder](images/eclipse_installer_03.png)
1. Once loaded, choose the JDK variant of your Java installation and click OK.
   ![Screenshot showing correct JVM selected](images/eclipse_installer_04.png)
1. Click next twice and then configure where you wish Eclipse to be installed, then click Next and then Finish.
   ![Screenshot of confirmation screen](images/eclipse_installer_05.png)
1. When prompted, accept the licenses and the unsigned content. Eclipse should launch automatically once completed. Choose any path as your workspace, though I personally choose `~/eclipse/workspace`.
   
## Installing the RTC 6.0.6 Eclipse plugin

1. Go to the [RTC 6.0.6 downloads page](https://jazz.net/downloads/rational-team-concert/releases/6.0.6?p=allDownloads) and download the _p2 Install Repository_. Save this archive to your Eclipse workspace folder.
1. Install the RTC Eclipse plugin by choosing _Help -> Install New Software..._ from the menu bar.
   ![Screenshot showing step 4](images/rtc_01.png)
1. In the _Install_ dialog click the  _Add_ button, then click _Archive_. Select the p2 archive you just downloaded which you should have saved to your Eclipse workspace folder and click _Add_.
   ![Screenshot showing step 5](images/rtc_02.png)
1. Select the _Rational Team Concert Client_ plugin from the list then click through the remaining dialogs to install the plugin.
    ![Screenshot showing step 6](images/rtc_03.png)
1. Approve the installation of the unsigned plugin, and then restart RTC when prompted.

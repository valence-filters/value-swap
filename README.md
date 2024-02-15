# Value Swap

This is a custom extension for <a href="https://valence.app">Valence</a>, a <a href="https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000EORP4UAP">managed package on the Salesforce AppExchange</a> that provides integration middleware natively in a Salesforce org.

To learn more about developing extensions for the Valence platform, have a look at <a href="https://docs.valence.app">the Valence documentation</a>.

## Installing

Click this button to install the Filter into your org.

<a href="https://githubsfdeploy.herokuapp.com?owner=valence-filters&repo=value-swap&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## What Does This Filter Do?

Allows you to specify a list of values and which value they should be replaced with. Quick and easy way to line up mismatched picklists.

If you start to outgrow this Filter you should put your swap values into a reference table, then write a Filter that consults the reference table at runtime.

### Configuring the Filter

![Here's what configuring the Filter looks like](/images/configuring.png)

### What You See Once Configured

![Each configuration explains what it is going to do](/images/explainer.png)

### Effect on Records

As you can see, values that don't match are left alone to carry through.

![Here is the impact on the records at runtime](/images/results.png)

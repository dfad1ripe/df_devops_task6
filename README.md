# Task6-cookbook

- Installs IIS.

- Configures local mirror of Task6-content repository at IIS default
website directory.

- Configures regular mirror updates.


## Supported Platforms

Windows 2012 R2

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['Task6']['git']['package_url']</tt></td>
    <td>String</td>
    <td>Where to download git package</td>
  </tr>
  <tr>
    <td><tt>['Task6']['git']['package_name']</tt></td>
    <td>String</td>
    <td>DisplayName value for exact Git version in Windows registry</td>
  </tr>
  <tr>
    <td><tt>['Task6']['base']['subdir']</tt></td>
    <td>String</td>
    <td>Directory to place the scripts, relatively to system drive</td>
  </tr>
  <tr>
    <td><tt>['Task6']['repo']['url']</tt></td>
    <td>String</td>
    <td>GitHub repository to clone</td>
  </tr>
</table>

## Q & A

**Q:** How to check that content changed?

**A:** Several options exist. We can check the contents of
.git/FETCH_HEAD file, or (if we are paranoic) calculate a checksum
of entire repo. In this implementation, I'm checking an output of
'git pull <...>' to contain 'Updating' substring.

**Q:** How to restart IIS on the specific event?

**A:** Depends on the event. Some events, like triggering network
interfaces, can be intercepted by system triggers (sc triggerinfo...).
Other can be handled by a code that runs on a regular manner and restarts
corresponding windows service if some criteria was met.

**Q:** Which permissions needed to restart IIS?

**A:** IIS 7+ has 'Feature delegation' functionality that allows to
delegate these permissions to specific accounts. If this functionality
is not used, we are limited with LogOn parameters of w3svc service.
By default, this service is running from Local System account, so
Administrator is the only one with corresponding access rights.

**Q:** Which permissions needed to change content for IIS?

**A:** As above, 'Feature delegation' functionality in IIS 7+ allows to
delegate some permissions, like web deploy, to specific users. Also, static
content can be changed by anyone having corresponding directory access.

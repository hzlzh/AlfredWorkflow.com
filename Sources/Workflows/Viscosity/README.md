
Viscosity Workflow for Alfred
=============================

This is a workflow for [Alfred](http://www.alfredapp.com/) that
works with [Viscosity](http://www.sparklabs.com/viscosity/) to control
OpenVPN connections.

The configured keyword is `vpn`. That will show all of your configured
networks initially, and autocompletes (case-insensitively) on the
argument if one is provided.

The subtitle tells you if actioning the selection will connect or
disconnect from that network.

There are Connect All/Disconnect All operations that will act on
all VPN endpoints you've defined.

![Screenshot](viscosity.png)

Here's one way to import this workflow into Alfred:

    cd ~/Library/Application\ Support/Alfred\ 2/Alfred.alfredpreferences/workflows
    curl https://nodeload.github.com/andrewschleifer/viscosity-alfredworkflow/zip/master > \
        viscosity-alfredworkflow.zip
    unzip viscosity-alfredworkflow.zip
    rm viscosity-alfredworkflow.zip


Welcome to Chai PCR
===================

Chai PCR is a software platform that power's Chai's line of Real-Time PCR Thermocyclers including the [Open qPCR](https://www.chaibio.com/openqpcr) and related future devices. Chai PCR is released as open source to faciliate development of open source qPCR instruments and to welcome community contributions.

This software release is intended for developers, is provided as-is without warranty, and is not supported by [Chai](https://www.chaibio.com). Users of Chai's devices and Open qPCR should refer to [www.chaibio.com/openqpcr](https://www.chaibio.com/openqpcr) for device information and support, or [www.chaibio.com/about](https://www.chaibio.com/about) for more information about Chai.

Organization
------------
A brief description of the repository organization:

 * bioinformatics - Library code for the processing of qPCR bioinformatics data
 * browser - Qt application that powers device touchscreen
 * device - Template configuration files
 * devops - System for creating software builds and deploying to devices
 * frontend - JavaScript/HTML5 frontend web application for operating device & analyzing results
 * modules - Linux modules required by device
 * realtime - C++ application which operates the device in realtime for control and data aquisition
 * web - Ruby on Rails backend application for operating the device and managing experiments
 
License
-------
Chai PCR is released under the [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0)

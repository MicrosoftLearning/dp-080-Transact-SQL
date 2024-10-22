---
title: Online Hosted Instructions
permalink: index.html
layout: home
---

# Transact-SQL Exercises and Demonstrations

These exercises and demos support Microsoft course [DP-080: Querying with Transact-SQL](https://docs.microsoft.com/training/courses/dp-080t00) and the associated Microsoft Learn training content in the following learning paths:

- [Get started querying with Transact-SQL](https://docs.microsoft.com/training/paths/get-started-querying-with-transact-sql/)
- [Write advanced Transact-SQl queries](https://docs.microsoft.com/training/paths/write-advanced-transact-sql-queries/)
- [Program with Transact-SQL](https://docs.microsoft.com/training/paths/program-transact-sql/)

You can complete the exercises using:

-  A local installation of SQL Server
- Azure SQL Database

Setup instructions are provided for both of these options.

{% assign labs = site.pages | where_exp:"page", "page.url contains '/Instructions/Labs'" %}
| Module | Lab |
| --- | --- | 
{% for activity in labs  %}| {{ activity.lab.module }} | [{{ activity.lab.title }}{% if activity.lab.type %} - {{ activity.lab.type }}{% endif %}]({{ site.github.url }}{{ activity.url }}) |
{% endfor %}

### Instructor demo's

{% assign demos = site.pages | where_exp:"page", "page.url contains '/Instructions/Demos'" %}
| Module | Demo |
| --- | --- | 
{% for activity in demos  %}| {{ activity.demo.module }} | [{{ activity.demo.title }}]({{ site.github.url }}{{ activity.url }}) |
{% endfor %}

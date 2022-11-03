After reading the Kimball book on Data Warehouses, I tried to create the dimentional model like this:
https://docs.google.com/spreadsheets/d/17nFQT_SOxjim0kf3kXpaWa03TOt-6wKrQojngvu8P8c/edit?usp=sharing

I modeled Provider as a Type 2 SCD, and created a date dimension using dbt-utils date spine macro.

| Business Process         | Common Dimensions |          |          |          |          |
| ------------------------ | ----------------- | -------- | -------- | -------- | -------- |
|                          | Date              | Provider | Consumer | Location | Schedule |
| Event Ticketing          | x                 | x        | x        |          | x        |
| Membership Subscriptions | x                 | x        |          |          |          |
| Promoted Listings        | x                 | x        |          |          |          |
| Consumer searches        |                   |          |          |          |          |
| Newsletter Subscriptions | x                 |          | x        |          |          |
| Provider registrations   |                   |          |          |          |          |
| Customer Support         | x                 | x        |          |          |          |

Data is stored here in Google BigQuery
https://console.cloud.google.com/bigquery?project=fifth-battery-131115

We use Airbyte to get the data across.
https://cloud.airbyte.io/workspaces/6866bdd6-0137-46fb-ba97-33fea37ac674

We translate data into models suitable for reporting with DBT.
https://cloud.getdbt.com/#/accounts/55416/projects/88664/dashboard/

The DBT code is here (and I've invited Becky and Sara as a collaborator)
https://github.com/amcvitty/dbt-happity

### Terminology match-up between BigQuery, DBT and AirByte

- In DBT each developer has a dev **target schema** used for **development** configured in their personal settings for the project under Profile > Credentials: (e.g. https://cloud.getdbt.com/#/profile/projects/88664/credentials/). Mine is `dbt_amcvitty`
- The **deployment** environment has its own target schema, `analytics`
- **Source schemas** are shared between dev/prod
- We rebuild every day from source schemas. DBT does allow "incremental" materializations, but that is an optimisation if the batch takes too long. And we're not there yet!

this is a video
Improving data reliability
https://www.youtube.com/watch?v=M_cNspn2XsE

## DBT Learning

Definitely do the **DBT Fundamentals** course to get up to speed on the DBT environment, which will allow you to create new views on data accessible from Datastudio. It takes 4-5 hours, and is worth the time.

https://courses.getdbt.com/collections
https://courses.getdbt.com/account/certificates

models/staging/X contains the info for the source and the corresponding stg\_ model

### DBT notes (from fundamentals course)

Writing models:

- A model is a SQL Select statement in a `*.sql` file
- Use `{{ ref('stg_customers') }}` to refer to other models
- Use `{{ source('jaffle_shop','customers') }}` to refer to a source

Writing sources

- Configured in `*.yml` files

```yaml
version: 2

sources:
  - name: jaffle_shop
    database: raw
    schema: jaffle_shop
    tables:
      - name: orders
        loaded_at_field: _etl_loaded_at
        freshness:
          warn_after: {count: 12, period: hour}
          error_after: {count: 24, period: hour}
```

Conventions for naming our models:

- **Sources** (`src`) refer to the raw table data that have been built in the warehouse through a loading process. (We will cover configuring Sources in the Sources module)
- **Staging** (`stg`) refers to models that are built directly on top of sources. These have a one-to-one relationship with sources tables. These are used for very light transformations that shape the data into what you want it to be. These models are used to clean and standardize the data before transforming data downstream. Note: These are typically materialized as views.
- **Intermediate** (`int`) refers to any models that exist between final fact and dimension tables. These should be built on staging models rather than directly on sources to leverage the data cleaning that was done in staging.
- **Fact** (`fct`) refers to any data that represents something that occurred or is occurring. Examples include sessions, transactions, orders, stories, votes. These are typically skinny, long tables.
- **Dimension** (`dim`) refers to data that represents a person, place or thing. Examples include providers, consumers, events, schedules, employees.
- Note: The Fact and Dimension convention is based on "dimensional modeling" techniques. - specifically Kimball's book.

Folders:

- **Marts** folder: All intermediate, fact, and dimension models can be stored here. Further subfolders can be used to separate data by business function (e.g. marketing, finance)
- **Staging** folder: All staging models and source configurations can be stored here. Further subfolders can be used to separate data by data source (e.g. Stripe, Segment, Salesforce). (We will cover configuring Sources in the Sources module)

## Running

`dbt run -s staging` will run all models that exist in `models/staging`
`dbt run -s stg_bookings` will run all models that exist in `models/staging`

## Slow-Changing Dimensions

For dimensions that change over time, we need to make a decision on how to handle it. Our example is providers, because a provider might start being a member, then stop etc. We wouldn't want old bookings from a provider that was a member at the time of the booking to look like a non-member was doing bookings. So we track info over time.

This is a moderately hard thing to do! So we made use of Airbyte's built-in "Incremental | Deduped + history" mode in our postgres -> BigQuery Connection and the `updated_at` field as a cursor. This creates `_airbyte_start_at` and `_airbyte_end_at` fields in the source table.

However, since we use the updated_at field as a cursor, and we started the syncs long after the data was first created, we needed to extend the range of the start_at/end_at to encompass the earlier period. So I did this once to extend the first row of each provider back to when it was created, then the same for schedules & companies

```sql
update `fifth-battery-131115.happity_prod_db.providers_scd`
set  _airbyte_start_at = created_at
where _airbyte_unique_key_scd in (
    with providers as (
	    select * from `fifth-battery-131115.happity_prod_db.providers_scd`
    )
    select _airbyte_unique_key_scd from providers a where not exists (
        -- exclude all but the first row.
        select 1 from providers b
        where b.id = a.id and b._airbyte_start_at < a._airbyte_start_at
        )
    and created_at < _airbyte_start_at
)
```

**TODO** - example of a join, reference ot the scd keys

## Development

Developing in DBT looks like

- Open DBT cloud dev environment
- Create a git branch for your changes
- Make changes to models, running with Cmd-Enter to run the SQL you're looking at.
- Use `dbt run` to create the views in your dev target dataset (e.g. dbt_amcvitty).
- Use Datastudio on your dev target dataset to verify things look good.
- Use git to Commit etc. like regular coding
- Create PR, review
- Merge to main. This effectively deploys to production. The next production job run will use your changes and run with `analytics` as the target dataset. To see the changes immediately you can kick off a job manually.

## Outstanding issues

#### Materialised Models

For some reason, when I tried to materialise our models as tables rather than views, it worked in dev, then failed in production. As such, it's possible that our Datastudio usage will be slower and query more data. This probably isn't a big problem, but it might be worth thinking about. Maybe ask the DBT people about this...

#### Date view for stripe subscriptions

Stripe data doesn't match easily onto the time view, which is a bit sad! We just have the current snapshot. However, the subscriptions all have a start and end date.

Options:

- Start a SCD type thing for the subscriptions
- Use a date spine, then join to the subscriptions table and check whether the subscription was active on that date.

#### Modeling the "subscription" stripe product (vs adhoc)

I deliberately excluded "metered" stripe subscriptions to exclude the promoted listings, but we're actually using a metered model for Happy Hands, so that's not showing anywhere. The data is there, but we'd need to look into how.

#### Invoice - Subscription data

We'd need to include invoice items to be able to match the invoices to the subscriptions.

#### Locations

I haven't got around to adding location to dim_provider, which is a crying shame because some of what we could do with geo visualisation is amazing.

This [article about creating a heatmap visualisation](https://datasciencecampus.github.io/creating-choropleth-maps-in-google-data-studio/) shows a UK county map, using this [Counties and Unitary Authorities data set](https://datastudio.google.com/reporting/4617cbac-3514-4c8d-a999-a3cb6683e579) from ONS. It includes a

Here are some videos from google that are really exciting about Geographic Visualisation in general
https://cloud.google.com/bigquery/docs/geospatial-intro?hl=en_US - exciting video!
https://cloud.google.com/bigquery/docs/geospatial-visualize

It would be possible for us to create custom WKT target areas instead of the crude filters we have right now.

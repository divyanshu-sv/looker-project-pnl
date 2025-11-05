view: geography_dimension {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `Profit_and_Loss_Dataset.Geography_Dimension` ;;
  drill_fields: [geo_id]

  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: geo_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.geo_id ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "City" in Explore.

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  # --- Dynamic Drill-Down Logic ---

  parameter: drill_level {
    label: "Geography Drill Level"
    type: string
    allowed_value: { label: "Country" value: "country" }
    allowed_value: { label: "State" value: "state" }
    allowed_value: { label: "City" value: "city" }
    default_value: "country"
  }

  dimension: drilldown_location {
    label: "Location (Dynamic)"
    type: string
    sql:
      CASE
        WHEN {% parameter drill_level %} = "country" THEN ${country}
        WHEN {% parameter drill_level %} = "state" THEN ${state}
        WHEN {% parameter drill_level %} = "city" THEN ${city}
        ELSE ${country}
      END ;;
  }

  # --- Original Measure ---

  measure: count {
    type: count
    drill_fields: [geo_id]
  }
}

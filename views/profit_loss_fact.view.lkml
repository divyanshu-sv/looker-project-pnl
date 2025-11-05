# The name of this view in Looker is "Profit Loss Fact"


view: profit_loss_fact {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `Profit_and_Loss_Dataset.Profit_Loss_Fact` ;;

  dimension: transaction_id {
    primary_key: yes  # <-- ADDED THIS: Set as primary key for joins
    type: number
    sql: ${TABLE}.transaction_id ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Cost Amount" in Explore.

  dimension: cost_amount {
    type: number
    sql: ${TABLE}.cost_amount ;;
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}.customer_id ;;
  }
  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }

  dimension: date_id {
    type: number
    sql: ${TABLE}.date_id ;;
  }

  dimension: dept_id {
    type: number
    sql: ${TABLE}.dept_id ;;
  }

  dimension: geo_id {
    type: number
    sql: ${TABLE}.geo_id ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: profit_amount {
    type: number
    sql: ${TABLE}.profit_amount ;;
  }

  dimension: sales_amount {
    type: number
    sql: ${TABLE}.sales_amount ;;
  }

  # --- 🌟 ADDED OFFSET DIMENSIONS 🌟 ---
  # These dimensions use SQL LAG() to get the value from the previous
  # row, when ordered by date. This is a DIMENSION, not a MEASURE.

  dimension: previous_row_sales {
    label: "Previous Row's Sales Amount"
    type: number
    value_format: "$#,##0.00"
    sql:
      LAG(${sales_amount}, 1) OVER (
        ORDER BY ${date_raw} ASC
      ) ;;
    # '1' = offset by 1 row
    # 'ORDER BY ${date_raw} ASC' = sorts by the raw date before lagging
    }

    dimension: previous_row_profit {
      label: "Previous Row's Profit Amount"
      type: number
      value_format: "$#,##0.00"
      sql:
      LAG(${profit_amount}, 1) OVER (
        ORDER BY ${date_raw} ASC
      ) ;;
    }

    # --- Requested Measures for Total Values ---

    measure: total_sales {
      type: sum
      sql: ${sales_amount} ;;
      label: "Total Sales"
      value_format: "$#,##0.00"
    }

    measure: total_cost {
      type: sum
      sql: ${cost_amount} ;;
      label: "Total Cost"
      value_format: "$#,##0.00"
    }

    measure: total_profit {
      type: sum
      sql: ${profit_amount} ;;
      label: "Total Profit"
      value_format: "$#,##0.00"
    }

    measure: count {
      type: count
      drill_fields: [transaction_id] # <-- Added drill field
    }

    # --- Dynamic Measure Parameter and Field ---

    parameter: select_metric {
      type: string
      label: "Select Metric"
      allowed_value: {
        label: "Sales"
        value: "sales"
      }
      allowed_value: {
        label: "Cost"
        value: "cost"
      }
      allowed_value: {
        label: "Profit"
        value: "profit"
      }
    }

    measure: selected_dynamic_measure {
      type: number
      label: "Selected Dynamic Measure"
      value_format: "$#,##0.00"
      sql:
      CASE
        WHEN {% parameter select_metric %} = 'sales' THEN ${total_sales}
        WHEN {% parameter select_metric %} = 'cost' THEN ${total_cost}
        WHEN {% parameter select_metric %} = 'profit' THEN ${total_profit}
        ELSE NULL
      END
    ;;
    }

# --- 🌟 ADD THIS PARAMETER FOR TOP N 🌟 ---

  parameter: top_n_input {
    label: "Top N Count"
    type: number
    default_value: "10"
    description: "Enter a number (e.g., 5, 10) to filter for the Top N. Use with 'Is Top N' table calculation."
  }

  # --- End of view ---
  }

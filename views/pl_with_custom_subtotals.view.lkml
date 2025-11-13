# This is a NEW view file, e.g., pl_with_custom_subtotals.view.lkml

view: pl_with_custom_subtotals {
  derived_table: {
    sql:
      -- Query 1: The Detail Rows (SUM of sales by product)
      SELECT
        'detail' AS row_type,
        dept_id,
        CAST(product_id AS STRING) AS product_display_label,
        SUM(sales_amount) AS sales_metric
      FROM ${profit_loss_fact.SQL_TABLE_NAME}  -- This references your existing view's table!
      GROUP BY 1, 2, 3

      UNION ALL

      -- Query 2: The Custom Subtotal Rows (AVERAGE of sales by dept)
      SELECT
      'subtotal' AS row_type,
      dept_id,
      'Department Subtotal' AS product_display_label, -- This is our custom label
      AVG(sales_amount) AS sales_metric
      FROM ${profit_loss_fact.SQL_TABLE_NAME}
      GROUP BY 1, 2, 3
      ;;
  }

  # --- Dimensions ---

  dimension: row_type {
    type: string
    sql: ${TABLE}.row_type ;;
    hidden: yes # Used for filtering, not for display
  }

  dimension: dept_id {
    type: number
    sql: ${TABLE}.dept_id ;;
    # This field can now be used to join to your 'departments' dimension table
  }

  # This single dimension will show EITHER the product ID or the subtotal label
  dimension: product_display_label {
    type: string
    sql: ${TABLE}.product_display_label ;;
    label: "Product / Subtotal"
  }

  # --- Measure ---

  # The measure is now dead simple.
  # The hard logic is already done in the SQL.
  measure: dynamic_metric {
    type: sum
    sql: ${TABLE}.sales_metric ;;
    value_format: "$#,##0.00"
    label: "Dynamic Sales (Sum/Avg)"
  }
}

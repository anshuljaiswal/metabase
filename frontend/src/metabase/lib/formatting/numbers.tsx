import React from "react";

import { format_number } from "cljs/metabase.shared.formatting.numbers";
import { kebab_keys } from "cljs/metabase.shared.util";
import { getCurrencySymbol } from "./currency";

interface FormatNumberOptionsType {
  compact?: boolean;
  currency?: string;
  currency_style?: string;
  maximum_fraction_digits?: number;
  minimum_fraction_digits?: number;
  minimum_integer_digits?: number;
  maximum_significant_digits?: number;
  minimum_significant_digits?: number;
  negative_in_parentheses?: boolean;
  number_separators?: string;
  number_style?: string;
  scale?: number;
}

export function formatNumber(
  number: number,
  options: FormatNumberOptionsType = {},
): string {
  return format_number(number, kebab_keys(options));
}

# frozen_string_literal: true

class IMICFPS
  module Scripting
    CONSTANTS_WHITELIST = [
      # Basic types
      Array, Hash, String, Math, Time, Struct, Integer, Float, Numeric, Range, Proc,
      # Ruby information
      RUBY_VERSION, RUBY_ENGINE,
      # Local
      Vector, BoundingBox, Ray
    ].freeze

    METHOD_WHITELIST = [
      Subscription.subscribable_events,
      :|, :<, :<<, :>, :>>, :<=, :>=, :<=>, :==, :===, :=~, :[], :[]=,
      # Maths
      :+, :%, :*, :/, :-, :&, :**,
      :acos, :acosh, :asin, :asinh, :atan, :atan2, :atanh, :cbrt, :cos, :cosh,
      :erf, :erfc, :exp, :frexp, :gamma, :hypot, :ldexp, :lgamma, :log, :log10, :log2,
      :sin, :sinh, :sqrt, :tan, :tanh,
      # Keywords
      :do, :if, :else, :elsif, :case, :when, :and, :or,
      # Object
      :new, :class, :name, :clone, :dup,
      # Proc
      :call,
      # Time
      :at, :now, :utc, :gm, :local, :mktime,
      # Printing
      :inspect, :puts, :print, :console, :stdin,
      # Querying
      :between?, :block_given?, :is_a?, :kind_of?, :instance_of?, :empty?, :respond_to?, :equal?,
      # String
      :ascii_only?, :b, :bytes, :bytesize, :byteslice, :capitalize, :capitalize!, :casecmp, :casecmp?, :center, :chars,
      :chomp, :chomp!, :chop, :chop!, :chr, :clear, :codepoints, :concat, :count, :crypt, :delete, :delete!, :delete_prefix,
      :delete_prefix!, :delete_suffix, :delete_suffix!, :downcase, :downcase!, :dump, :each_byte, :each_char, :each_codepoint,
      :each_grapheme_cluster, :each_line, :empty?, :encode, :encode!, :encoding, :end_with?, :eql?, :force_encoding, :freeze, :getbyte,
      :grapheme_clusters, :gsub, :gsub!, :hash, :hex, :include?, :index, :insert, :inspect, :intern, :length, :lines, :ljust, :lstrip,
      :lstrip!, :match, :match?, :next, :next!, :oct, :ord, :partition, :prepend, :replace, :reverse, :reverse!, :rindex, :rjust, :rpartition,
      :rstrip, :rstrip!, :scan, :scrub, :scrub!, :setbyte, :size, :slice, :slice!, :split, :squeeze, :squeeze!, :start_with?, :strip, :strip!,
      :sub, :sub!, :succ, :succ!, :sum, :swapcase, :swapcase!, :tr, :tr!, :tr_s, :tr_s!, :undump, :unicode_normalize, :unicode_normalize!,
      :unicode_normalized?, :unpack, :unpack1, :upcase, :upcase!, :upto, :valid_encoding?,
      # Array/Hash/Enumerable
      :all?, :any?, :append, :assoc, :at, :bsearch, :bsearch_index, :chain, :chunk, :chunk_while, :clear, :collect, :collect!, :collect_concat,
      :combination, :compact, :compact!, :compare_by_identity, :compare_by_identity?, :concat, :count, :cycle, :default, :default=, :default_proc,
      :default_proc=, :delete, :delete_at, :delete_if, :detect, :difference, :dig, :drop, :drop_while, :each, :each_cons, :each_entry, :each_index,
      :each_key, :each_pair, :each_slice, :each_value, :each_with_index, :each_with_object, :empty?, :entries, :eql?, :fetch, :fetch_values, :fill,
      :filter, :filter!, :find, :find_all, :find_index, :first, :flat_map, :flatten, :flatten!, :grep, :grep_v, :group_by, :has_key?, :has_value?,
      :hash, :include?, :index, :inject, :insert, :inspect, :invert, :join, :keep_if, :key, :key?, :keys, :last, :lazy, :length, :map, :map!,
      :max, :max_by, :member?, :merge, :merge!, :min, :min_by, :minmax, :minmax_by, :none?, :one?, :pack, :partition, :permutation, :pop, :prepend,
      :product, :push, :rassoc, :reduce, :rehash, :reject, :reject!, :repeated_combination, :repeated_permutation, :replace, :reverse, :reverse!,
      :reverse_each, :rindex, :rotate, :rotate!, :sample, :select, :select!, :shift, :shuffle, :shuffle!, :size, :slice, :slice!, :slice_after, :slice_before,
      :slice_when, :sort, :sort!, :sort_by, :sort_by!, :store, :sum, :take, :take_while, :to_a, :to_ary, :to_h, :to_hash, :to_proc, :to_s, :to_set,
      :transform_keys, :transform_keys!, :transform_values, :transform_values!, :transpose, :union, :uniq, :uniq!, :unshift, :update, :value?, :values,
      :values_at, :zip,
      # Casting
      :to_c, :to_f, :to_i, :to_r, :to_str, :to_ary, :to_h, :to_hash, :to_proc, :to_a, :to_s, :to_sym
    ].flatten
  end
end

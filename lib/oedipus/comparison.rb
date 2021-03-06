# encoding: utf-8

##
# Oedipus Sphinx 2 Search.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

module Oedipus
  # Represents a comparison operator and value.
  class Comparison
    class << self
      # Return a suitable comparison object for +v+.
      #
      # The conversions are:
      #
      #   - leave Comparison objects unchanged
      #   - convert real ranges to Between comparisons
      #   - convert Infinity-bounded exclusive ranges to GT/LT comparisons
      #   - convert Infinity-bounded inclusive ranges to GTE/LTE comparisons.
      #   - convert everything else to an Equal comparison
      #
      # @param [Object] v
      #   a ruby object to be compared
      #
      # @param [Comparison]
      #   a comparison suitable for comparing the input
      def of(v)
        case v
        when Comparison
          v
        when Range
          if v.end == Float::INFINITY
            v.exclude_end? ? Shortcuts.gt(v.first) : Shortcuts.gte(v.first)
          elsif v.first == -Float::INFINITY
            v.exclude_end? ? Shortcuts.lt(v.end) : Shortcuts.lte(v.end)
          else
            Shortcuts.between(v)
          end
        when Enumerable
          Shortcuts.in(v)
        else
          Shortcuts.eq(v)
        end
      end
    end

    attr_reader :v

    # Initialize a new Comparison for +v+.
    #
    # @param [Object] v
    #   any ruby object to compare
    def initialize(v)
      @v = v
    end

    # Compare two comparisons for equality.
    #
    # @param [Comparison] other
    #   another comparison to check
    #
    # @return [Boolean]
    #   true if the comparisons are the same
    def ==(other)
      other.class == self.class && other.v == v
    end

    alias_method :eql?, :==

    # Return the exact inverse of this comparison.
    #
    # @return [Comparison]
    #   the inverse of the current comparison
    def inverse
      raise NotImplementedError, "Comparison#inverse must be defined by subclasses"
    end

    # Represent the comparison as SQL arguments.
    #
    # @return [Array]
    #   an SQL expression to compare a LHS against v
    def to_sql
      raise NotImplementedError, "Comparison#to_sql must be defined by subclasses"
    end
  end
end

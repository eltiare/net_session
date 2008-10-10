# The blank classes
class NilClass; def blank?; true; end; end unless NilClass.respond_to?(:blank?)
class String; def blank?; match(/^\s*$/) ? true: false; end; end unless String.respond_to?(:blank?)
[Hash, Array].each { |klass| klass.class_eval {def blank?; size == 0; end} unless klass.respond_to?(:blank?)}
class Object; def blank?; false; end; end unless Object.respond_to?(:blank?)
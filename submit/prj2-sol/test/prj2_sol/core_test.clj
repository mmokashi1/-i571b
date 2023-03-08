(ns prj2-sol.core-test
  (:require [clojure.test :refer :all]
            [prj2-sol.core :refer :all]))

(def ITEM-1 (->OrderItem :cw123 :cookware 3 12.50))
(def ITEM-2 (->OrderItem :cw126 :cookware 2 11.50))
(def ITEM-3 (->OrderItem :ap723 :apparel 2 10.50))
(def ITEM-4 (->OrderItem :cw127 :cookware 1 9.99))
(def ITEM-5 (->OrderItem :ap273 :apparel 3 21.50))
(def ITEM-6 (->OrderItem :fd825 :food  1 2.48))

(def COOKWARE (list ITEM-1 ITEM-2 ITEM-4))
(def APPAREL (list ITEM-3 ITEM-5))

(def ITEMS (list
  ITEM-1 ITEM-2 ITEM-3 ITEM-4 ITEM-5 ITEM-6
))


;;Utility functions to allow testing same specs with different
;;fn implementations

(defn test-items-with-category [fn]
  (testing fn
    (is (= (fn ITEMS :cookware) COOKWARE))
    (is (= (fn ITEMS :apparel) APPAREL))
    (is (= (fn ITEMS :food) (list ITEM-6)))
    (is (= (fn ITEMS :electronics) '()))))

(defn test-items-total [fn]
  (testing fn
    (is (= (fn ITEMS) (+ (* 3 12.5) (* 2 11.5) (* 2 10.5) (* 1 9.99)
                         (* 3 21.5) (* 1 2.48))))
    (is (= (fn (list ITEM-2 ITEM-5)) (+ (* 2 11.5) (* 3 21.5))))
    (is (= (fn ()) 0))))


;;use to define a test currently being skipped
(defmacro skip-deftest [& _] :SKIP)

;;TESTS

(deftest test-items-total1
  (test-items-total items-total1))

(deftest test-items-with-category1
  (test-items-with-category items-with-category1))

(deftest test-items-total2
  (test-items-total items-total2))

(deftest test-item-skus
  (testing "item-skus"
    (is (= (item-skus (list ITEM-1 ITEM-3)) (list :cw123 :ap723)))
    (is (= (item-skus ()) ()))))

(deftest test-expensive-item-skus
  (testing "expensive-item-skus"
    (is (= (expensive-item-skus ITEMS 12) (list :cw123 :ap273)))
    (is (= (expensive-item-skus ITEMS 20) (list :ap273)))
    (is (= (expensive-item-skus ITEMS 30) ()))))

(deftest test-items-total3
  (test-items-total items-total3))

(deftest test-items-with-category2
  (test-items-with-category items-with-category2))


(deftest test-item-category-n-units
  (testing "item-category-n-units"
    (is (= (item-category-n-units ITEMS) 12))
    (is (= (item-category-n-units ITEMS :food) 1))
    (is (= (item-category-n-units ITEMS :cookware) 6))
    (is (= (item-category-n-units ITEMS :electronics) 0))))


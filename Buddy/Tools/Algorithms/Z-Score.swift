//
//  Z-Score.swift
//  Buddy
//
//  Created by Magnus Burton on 2021-03-19.
//

import Foundation

/** Smooth z-score thresholding filter
	- Parameter lag: The `lag` parameter determines how much your data will be smoothed and how adaptive the algorithm is to changes in the long-term average of the data. The more stationary your data is, the more lags you should include (this should improve the robustness of the algorithm). If your data contains time-varying trends, you should consider how quickly you want the algorithm to adapt to these trends. I.e., if you put `lag` at `10`, it takes `10` 'periods' before the algorithm's `threshold` is adjusted to any systematic changes in the long-term average. So choose the `lag` parameter based on the trending behavior of your data and how adaptive you want the algorithm to be.
	- Parameter influence: This parameter determines the `influence` of signals on the algorithm's detection `threshold`. If put at `0`, signals have no `influence` on the `threshold`, such that future signals are detected based on a `threshold` that is calculated with a mean and standard deviation that is not influenced by past signals. If put at `0.5`, signals have half the `influence` of normal data points. Another way to think about this is that if you put the `influence` at `0`, you implicitly assume stationarity (i.e. no matter how many signals there are, you always expect the time series to return to the same average over the long term). If this is not the case, you should put the `influence` parameter somewhere between `0` and `1`, depending on the extent to which signals can systematically influence the time-varying trend of the data. E.g., if signals lead to a structural break of the long-term average of the time series, the `influence` parameter should be put high (close to `1`) so the `threshold` can react to structural breaks quickly.
	- Parameter threshold: The `threshold` parameter is the number of standard deviations from the moving mean above which the algorithm will classify a new datapoint as being a signal. For example, if a new datapoint is `4.0` standard deviations above the moving mean and the threshold parameter is set as `3.5`, the algorithm will identify the datapoint as a signal. This parameter should be set based on how many signals you expect. For example, if your data is normally distributed, a threshold (or: z-score) of `3.5` corresponds to a signaling probability of `0.00047` (from this table), which implies that you expect a signal once every `2128` datapoints (`1/0.00047`). The threshold therefore directly influences how sensitive the algorithm is and thereby also determines how often the algorithm signals. Examine your own data and choose a sensible threshold that makes the algorithm signal when you want it to (some trial-and-error might be needed here to get to a good threshold for your purpose).

	- Author: https://stackoverflow.com/a/22640362/2365602
*/
func ThresholdingAlgo(y: [Double], lag: Int = 10, threshold: Double = 3, influence: Double = 0.2) -> ([Int], [Double], [Double]) {
	
	// Create arrays
	var signals   = Array(repeating: 0, count: y.count)
	var filteredY = Array(repeating: 0.0, count: y.count)
	var avgFilter = Array(repeating: 0.0, count: y.count)
	var stdFilter = Array(repeating: 0.0, count: y.count)
	
	// Initialise variables
	for i in 0...lag-1 {
		signals[i] = 0
		filteredY[i] = y[i]
	}
	
	/// Function to calculate the arithmetic mean
	func arithmeticMean(array: [Double]) -> Double {
		var total: Double = 0
		for number in array {
			total += number
		}
		return total / Double(array.count)
	}
	
	/// Function to calculate the standard deviation
	func standardDeviation(array: [Double]) -> Double {
		let length = Double(array.count)
		let avg = array.reduce(0, {$0 + $1}) / length
		let sumOfSquaredAvgDiff = array.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
		return sqrt(sumOfSquaredAvgDiff / length)
	}
	
	/// Function to extract some range from an array
	func subArray<T>(array: [T], s: Int, e: Int) -> [T] {
		if e > array.count {
			return []
		}
		return Array(array[s..<min(e, array.count)])
	}
	
	// Start filter
	avgFilter[lag-1] = arithmeticMean(array: subArray(array: y, s: 0, e: lag-1))
	stdFilter[lag-1] = standardDeviation(array: subArray(array: y, s: 0, e: lag-1))
	
	for i in lag...y.count-1 {
		if abs(y[i] - avgFilter[i-1]) > threshold*stdFilter[i-1] {
			if y[i] > avgFilter[i-1] {
				signals[i] = 1      // Positive signal
			} else {
				signals[i] = -1       // Negative signal
			}
			filteredY[i] = influence*y[i] + (1-influence)*filteredY[i-1]
		} else {
			signals[i] = 0          // No signal
			filteredY[i] = y[i]
		}
		// Adjust the filters
		avgFilter[i] = arithmeticMean(array: subArray(array: filteredY, s: i-lag, e: i))
		stdFilter[i] = standardDeviation(array: subArray(array: filteredY, s: i-lag, e: i))
	}
	
	return (signals, avgFilter, stdFilter)
}

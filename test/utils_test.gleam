import gleeunit/should
import utils

pub fn random_range_test() {
  // Test with positive range
  let result1 = utils.random_range(1, 10)
  case result1 {
    r if r >= 1 && r <= 10 -> True
    _ -> False
  }
  |> should.be_true

  // Test with single value range
  let result2 = utils.random_range(5, 5)
  result2
  |> should.equal(5)

  // Test with negative numbers
  let result3 = utils.random_range(-5, -1)
  case result3 {
    r if r >= -5 && r <= -1 -> True
    _ -> False
  }
  |> should.be_true
}

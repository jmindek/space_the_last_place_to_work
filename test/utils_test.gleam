import utils

pub fn random_range_test() {
  // Test with positive range
  let result1 = utils.random_range(1, 10)
  assert result1 >= 1 && result1 <= 10

  // Test with single value range
  let result2 = utils.random_range(5, 5)
  assert result2 == 5

  // Test with negative numbers
  let result3 = utils.random_range(-5, -1)
  assert result3 >= -5 && result3 <= -1
}

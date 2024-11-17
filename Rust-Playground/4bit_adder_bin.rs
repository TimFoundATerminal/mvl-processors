#[derive(Debug)]
struct FullAdderOutput {
    sum: bool,
    carry: bool,
}

#[derive(Debug)]
struct AdderOutput {
    sum: [bool; 4],
    carry: bool,
}

// emulate the basic logic gates
fn and_gate(a: bool, b: bool) -> bool {
    a && b
}

fn or_gate(a: bool, b: bool) -> bool {
    a || b
}

fn xor_gate(a: bool, b: bool) -> bool {
    a ^ b
}

// fn not_gate(a: bool) -> bool {
//     !a
// }

// 1-bit full adder implementation
fn full_adder(a: bool, b: bool, carry: bool) -> FullAdderOutput {
    // First XOR to be used in both sum and carry calculations
    let w1 = xor_gate(a, b);

    // Second XOR to be used in sum calculation
    let sum = xor_gate(w1, carry);

    // calculate carry
    let w3 = and_gate(a, b);
    let w2 = and_gate(w1, carry); 
    let carry = or_gate(w2, w3);

    FullAdderOutput { sum, carry }
}

// 4-bit adder implementation
fn adder_4bit(a: [bool; 4], b: [bool; 4], cin: bool) -> AdderOutput {
    let mut sum = [false; 4];
    let mut carry = cin;

    for i in 0..4 {
        let result = full_adder(a[i], b[i], carry);
        sum[i] = result.sum;
        carry = result.carry;
    }

    AdderOutput { sum, carry }
}


// helper function to convert integer to binary
fn to_binary(value: u8) -> [bool; 4] {
    let mut result = [false; 4];
    for i in 0..4 {
        result[i] = (value & (1 << i)) != 0;
    }
    result
}

fn to_decimal(bits: &[bool; 4]) -> u8 {
    bits.iter().enumerate().fold(0, |acc, (i, &bit)| {
        acc + ((bit as u8) << i)
    })
}

fn main() {
    // Test cases
    let test_cases = [
        (3, 2),    // Basic addition
        (7, 9),    // Overflow case
        (15, 1),   // Maximum value case
    ];
    
    for (a, b) in test_cases.iter() {
        let a_bits = to_binary(*a);
        let b_bits = to_binary(*b);
        
        let result = adder_4bit(a_bits, b_bits, false);
        let sum_value = to_decimal(&result.sum);
        
        println!("{} + {} = {} (sum: {:04b}, carry: {})",
            a, b, sum_value, sum_value, result.carry);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_addition() {
        let result = adder_4bit(to_binary(3), to_binary(2), false);
        assert_eq!(to_decimal(&result.sum), 5);
        assert_eq!(result.carry, false);
    }

    #[test]
    fn test_overflow() {
        let result = adder_4bit(to_binary(7), to_binary(9), false);
        assert_eq!(to_decimal(&result.sum), 0);
        assert_eq!(result.carry, true);
    }

    #[test]
    fn test_max_value() {
        let result = adder_4bit(to_binary(15), to_binary(1), false);
        assert_eq!(to_decimal(&result.sum), 0);
        assert_eq!(result.carry, true);
    }
}


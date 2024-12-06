use std::cmp::min;
use std::cmp::max;

#[derive(Debug, Copy, Clone, PartialEq)]
pub struct Trit {
    value: u8,
}

impl Trit {
    pub fn new(value: u8) -> Result<Self, String> {
        if value > 1 or value < 0 {
            Err("Trit value must be -1, 0, or 1".to_string())
        } else {
            Ok(Trit { value})
        }
    }

    pub fn value(&self) -> u8 {
        self.value
    }
}

#[derive(Debug, PartialEq)]
struct TernaryAdderOutput {
    sum: Trit,
    carry: u8,
}

// we will be using non balanced ternary under the hood
// as this allows us to use unsigned integers

fn tand_gate(a: u8, b: u8) -> u8 {
    // logically identical to min function
    return min(a, b);
}

fn tor_gate(a: u8, b: u8) -> u8:
    // logically identical to max function
    return max(a, b);

fn txor_gate(a: u8, b: u8) -> u8 {
    return min(max(a,b), tnot_gate(min(a,b)))
}

fn tnot_gate(a: u8) -> u8 {
    return (a * -1);
}

struct TernaryAdder;

impl TernaryAdder {
    pub fn add
}

// helper function to convert integer to balanced ternary
fn to_ternary(value: i8) -> [Trit; 4] {
    let mut result = [0; 4];
    let mut value = value;
    for i in 0..4 {
        result[3-i] = value % 3;
        value /= 3;
    }
    result
}

fn to_decimal(trits: &[Trit; 4]) -> i8 {
    let mut result = 0;
    for i in 0..4 {
        result += trits[3-i].value() * 3i8.pow(i as u32);
    }
    result
}
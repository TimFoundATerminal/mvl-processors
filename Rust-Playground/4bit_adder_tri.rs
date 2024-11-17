use std::cmp::min;
use std::cmp::max;

#[derive(Debug, Copy, Clone, PartialEq)]
pub struct Trit {
    value: u8,
}

impl Trit {
    pub fn new(value: u8) -> Result<Self, String> {
        if value > 2 {
            Err("Trit value must be 0, 1, or 2".to_string())
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
    if a == 0 {
        return 2;
    } else if a == 2 {
        return 0;
    }
    return 1;
}

struct TernaryAdder;

impl TernaryAdder {
    pub fn add
}
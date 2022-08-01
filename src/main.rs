use std::ops::Deref;
use std::{collections::HashMap, cell::Ref};
use std::env;
use std::path::PathBuf;
use sv_parser::{parse_sv, unwrap_node, Locate, RefNode, CaseItem};
use RefNode::{CaseStatement, CaseItemNondefault};
use CaseItem::{NonDefault};

fn main() {
    let args: Vec<String> = env::args().collect();

    // The path of SystemVerilog source file
    let path = PathBuf::from(&args[1]);
    // The list of defined macros
    let defines = HashMap::new();
    // The list of include paths
    let includes: Vec<PathBuf> = Vec::new();

    // Parse
    let result = parse_sv(&path, &defines, &includes, false, false);

    if let Ok((syntax_tree, _)) = result {
        // &SyntaxTree is iterable
        for node in &syntax_tree {
            // The type of each node is RefNode
            match node {
                RefNode::ModuleDeclarationNonansi(x) => {
                    // unwrap_node! gets the nearest ModuleIdentifier from x
                    let id = unwrap_node!(x, ModuleIdentifier).unwrap();

                    let id = get_identifier(id).unwrap();

                    // Original string can be got by SyntaxTree::get_str(self, locate: &Locate)
                    let id = syntax_tree.get_str(&id).unwrap();
                    println!("module: {}", id);
                }
                RefNode::ModuleDeclarationAnsi(x) => {
                    let id = unwrap_node!(x, ModuleIdentifier).unwrap();
                    let id = get_identifier(id).unwrap();
                    let id = syntax_tree.get_str(&id).unwrap();
                    println!("module: {}", id);
                }
                RefNode::BlockIdentifier(x) => {
                    let id = unwrap_node!(x, BlockIdentifier).unwrap();
                    let id = get_identifier(id).unwrap();
                    let id = syntax_tree.get_str(&id).unwrap();
                    println!("block: {}", id);
                }
                // RefNode::AlwaysConstruct(x) => {
                //     println!("node: {}", x.nodes.1);
                //     let id = unwrap_node!(x, AlwaysConstruct).unwrap();
                //     let id = get_identifier(id).unwrap();
                //     let id = syntax_tree.get_str(&id).unwrap();
                //     println!("always construct: {}", id);
                // }
                RefNode::CaseStatementNormal(x) => {
                    let id = unwrap_node!(x, CaseStatementNormal).unwrap();
                    let id = get_identifier(id).unwrap();
                    let id = syntax_tree.get_str(&id).unwrap();
                    println!("case id: {}", id);
                    
                    // let id = unwrap_node!(x, CaseStatementInside).unwrap();
                    // let id = get_identifier(id).unwrap();
                    // let id = syntax_tree.get_str(&id).unwrap();
                    // println!("case statement inside: {}", id);
                    for case_item in x.nodes.4.clone() {
                        match case_item {
                            NonDefault(y) => {
                                let id = syntax_tree.get_str(&y.nodes.0.nodes.0.nodes.0).unwrap();
                                println!("y: {}", id);
                                            
                                // println!("symbol: {}", y.nodes.1);
                                // for case_expression in y.nodes.0.nodes.1 {
                                    
                                //     println!("case expressions: {:?}", case_expression.1.nodes.0);
                                // }
                            }
                            _ => ()
                            // sv_parser::CaseItem::Default(y) => {
                            //     println!("default item: {:?}", y.deref());
                            // }
                        }   
                    }
                }
                
                // RefNode::NamedPortConnection(x) => {
                //     let id = unwrap_node!(x, NamedPortConnection).unwrap();
                //     let id = get_identifier(id).unwrap();
                //     let id = syntax_tree.get_str(&id).unwrap();
                //     println!("named port connection: {}", id); 
                // }
                _ => ()
                // other => {
                //     println!("{}", other);
                // },
            }
        }
    } else {
        println!("Parse failed");
    }
}

fn get_identifier(node: RefNode) -> Option<Locate> {
    // unwrap_node! can take multiple types
    match unwrap_node!(node, SimpleIdentifier, EscapedIdentifier) {
        Some(RefNode::SimpleIdentifier(x)) => {
            return Some(x.nodes.0);
        }
        Some(RefNode::EscapedIdentifier(x)) => {
            return Some(x.nodes.0);
        }
        _ => None,
    }
}

//
//  ContentView.swift
//  SwiftUI-WordScramble
//
//  Created by 	Oleg2 on 06.07.2020.
//  Copyright © 2020 Oleg Pustoshkin. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var userdWords = [String]()
    @State private var giveMeAWord = ""
    @State private var navigationTitleWord = "Hello word"
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowAlert = false
    
    @State private var gameScore = 0
    
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Give me a word...", text: self.$giveMeAWord, onCommit: self.textFieldCommit)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                if self.userdWords.count > 0 {
                    Section(header: Text("Used words")) {
                        List(self.userdWords, id: \.self) {
                            Image(systemName: "\($0.count).circle")
                            Text($0)
                        }
                    }
                }
            }
            
            .navigationBarTitle(self.navigationTitleWord)
            .onAppear(perform: self.startGame)
            .navigationBarItems(leading: Button(action: self.resetGame, label: {
                Text("Reset game")
                .padding(.all, 10	)
                .background(Color.green)
                .cornerRadius(20)
            }), trailing: VStack(alignment: .trailing) {
                Text("Score: \(self.gameScore)")
                Text("Words count: \(self.userdWords.count)")
                
            })
/*            .navigationBarItems(trailing: )
            .navigationBarItems(leading: )*/
        }
        .alert(isPresented: self.$isShowAlert) {
                Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("Ok")))
            }
        
    }
    
    
    func startGame() {
        debugPrint(#function, #file)
        
        guard let fileWithWordsUrl = Bundle.main.url(forResource: "start", withExtension: ".txt") else {
            fatalError("Cant get url of file /main/start.txt")
            //return
        }
        
        do {
            let fileContent = try String(contentsOf: fileWithWordsUrl)
            
            let wordsList = fileContent.split(separator: "\n")
            
            if let randomWord = wordsList.randomElement() {
                let trimmedRandomWord = randomWord.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedRandomWord.count > 0 {
                    self.navigationTitleWord = trimmedRandomWord
                    debugPrint("Initial word", self.navigationTitleWord, #function, #file)
                    return
                }
            }
            
            fatalError("Cant get random words from list \(#function) \(#file)")
        } catch  {
            fatalError("Cant read content of start file \(error.localizedDescription) \(#function) \(#file)")
        }
        
    }
    
    func textFieldCommit() {
        debugPrint(#function, #file)
        
        var wordFromTextField = self.giveMeAWord.lowercased()
        wordFromTextField = wordFromTextField.trimmingCharacters(in: .whitespacesAndNewlines)
        if wordFromTextField.count == 0 {
            debugPrint("Text field not contain any non space symbols", #function, #file)
            self.giveMeAWord = ""
            return
        }
        
        if self.isNewWord(newWord: wordFromTextField) == false {
            self.showAlertError(alertTitle: "Word alredy exist", alertMessage: "You already used this word.\nPlease imagine new word and send it me again...")
            debugPrint("This word already used - \(wordFromTextField)")
            return
        }
        
        
        if self.isPossibleWord(newWord: wordFromTextField) == false {
            self.showAlertError(alertTitle: "Word contain restricted letters", alertMessage: "You word contain letters witch not exist in word \(self.navigationTitleWord).\nTry another word...")
            debugPrint("This word contains characters, that not exist in navigationTitleWord - \(wordFromTextField)")
            return
        }
        
        
        if self.isRealWord(newWord: wordFromTextField) == false {
            self.showAlertError(alertTitle: "I don't know this word", alertMessage: "I think this word '\(wordFromTextField.uppercased())' is not exist.\nTry another word...")
            debugPrint("This word not exist - \(wordFromTextField)")
            return
        }
        
        self.gameScore += wordFromTextField.count
        self.userdWords.append(wordFromTextField)
        self.giveMeAWord = ""
    }
    
    
    // This new word or is old word what we are already used
    func isNewWord(newWord: String) -> Bool {
        !self.userdWords.contains(newWord)
    }
    
    // All charS if new word must contained in navigationTitle word
    func isPossibleWord(newWord: String) -> Bool {
        var tempWord = self.navigationTitleWord
        
        for letterChar in newWord {
            if let letterFindPosition = tempWord.firstIndex(of: letterChar) {
                tempWord.remove(at: letterFindPosition)
            } else
            {
                return false // New word contain characters not using in navigationTitleWord
            }
        }
        
        return true
    }
    
    // This word exist
    func isRealWord(newWord: String) -> Bool {
        let textChecker = UITextChecker()
        let checkRange = NSRange(location: 0, length: newWord.utf16.count)
        
        let misspelledRand = textChecker.rangeOfMisspelledWord(in: newWord, range: checkRange, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRand.location == NSNotFound
    }
    
    func showAlertError(alertTitle: String, alertMessage: String) {
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.isShowAlert = true
        self.giveMeAWord = ""
    }
    
    
    
    func resetGame() {
        self.userdWords.removeAll()
        self.giveMeAWord = ""
        self.navigationTitleWord = "Hello word"
        
        self.alertTitle = ""
        self.alertMessage = ""
        self.isShowAlert = false
        
        self.gameScore = 0
        
        self.startGame()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

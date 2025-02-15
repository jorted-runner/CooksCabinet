//
//  UpdateEditFormView.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/13/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct UpdateEditFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State var vm: UpdateEditFormViewModel
    @State private var imagePicker = ImagePicker()
    @State private var showCamera = false
    @State private var cameraError: CameraPermission.CameraError?
    @State private var isGeneratingRecipe = false   
    var body: some View {
        NavigationStack {
            Form {
                if vm.isUpDating {
                    // Update Recipe Form
                   TextField("Title", text: $vm.title)
                    VStack {
                        if vm.data != nil {
                            Button("Clear Image") {
                                vm.clearImage()
                            }
                            .buttonStyle(.bordered)
                        }
                        HStack {
                            Button("Camera", systemImage: "camera") {
                                if let error = CameraPermission.checkPermissions() {
                                    cameraError = error
                                } else {
                                    showCamera.toggle()
                                }
                            }
                            .alert(
                                isPresented: .constant(cameraError != nil),
                                error: cameraError
                            ) { _ in
                                Button("OK") {
                                    cameraError = nil
                                }
                            } message: { error in
                                Text(error.recoverySuggestion ?? "Try again later")
                            }
                            .sheet(isPresented: $showCamera) {
                                UIKitCamera(selectedImage: $vm.cameraImage)
                                    .ignoresSafeArea()
                            }
                            PhotosPicker(selection: $imagePicker.imageSelection) {
                                Label("Photos", systemImage: "photo")
                            }
                            
                        }
                        .foregroundStyle(.white)
                        .buttonStyle(.borderedProminent)
                        Image(uiImage: vm.image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding()
                    }
                } else {
                    // New Recipe form
                    Text("Recipe Generator")
                    HStack {
                        Button("Camera", systemImage: "camera") {
                            if let error = CameraPermission.checkPermissions() {
                                cameraError = error
                            } else {
                                showCamera.toggle()
                            }
                        }
                        .alert(
                            isPresented: .constant(cameraError != nil),
                            error: cameraError
                        ) { _ in
                            Button("OK") {
                                cameraError = nil
                            }
                        } message: { error in
                            Text(error.recoverySuggestion ?? "Try again later")
                        }
                        .sheet(isPresented: $showCamera) {
                            UIKitCamera(selectedImage: $vm.cameraImage)
                                .ignoresSafeArea()
                        }
                        PhotosPicker(selection: $imagePicker.imageSelection) {
                            Label("Photos", systemImage: "photo")
                        }
                    }
                    .foregroundStyle(.white)
                    .buttonStyle(.borderedProminent)
                    Image(uiImage: vm.image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                    if vm.data != nil {
                        Button("Generate Recipe") {
                            isGeneratingRecipe = true  // Disable button
                            let ai = aiBrain()
                            ai.generateRecipe(
                                requestString: "Create a recipe based off of the ingredients in this image.",
                                data: vm
                            ) { response in
                                DispatchQueue.main.async {
                                    
                                    guard let response = response else {
                                        print("Failed to get a response from OpenAI.")
                                        return
                                    }
                                    
                                    // Extract the JSON part from the response
                                    guard let jsonString = ai.extractJSON(from: response),
                                          let jsonData = jsonString.data(using: .utf8) else {
                                        print("Failed to extract JSON from response")
                                        return
                                    }
                                    
                                    do {
                                        // Decode JSON into RecipeModel
                                        let decodedRecipe = try JSONDecoder().decode(RecipeAPIResponse.self, from: jsonData)
                                        
                                        // Update ViewModel properties
                                        vm.title = decodedRecipe.title
                                        vm.ingredients = decodedRecipe.ingredients
                                        vm.instructions = decodedRecipe.instructions
                                        vm.recipeDescription = decodedRecipe.recipeDescription
                                        print("\(vm.title)")
                                        ai.generateImage(
                                            title: vm.title,
                                            description: vm.recipeDescription,
                                            ingredients: vm.ingredients
                                        ) { response in
                                            DispatchQueue.main.async {
                                                guard let response = response else {
                                                    print("Failed to get a response from OpenAI.")
                                                    return
                                                }
                                                ai.downloadImage(from: response) { image in
                                                    guard let imageData = image?.jpegData(compressionQuality: 0.8) else { return }
                                                    
                                                    DispatchQueue.main.async {
                                                        print("Saving")
                                                        vm.data = imageData
                                                        let newRecipe = RecipeModel(
                                                            title: vm.title,
                                                            ingredients: vm.ingredients,
                                                            instructions: vm.instructions,
                                                            imageData: vm.data,
                                                            recipeDescription: vm.recipeDescription
                                                        )
                                                        if vm.image != Constants.placeholder {
                                                            newRecipe.data = vm.image.jpegData(compressionQuality: 0.8)
                                                        } else {
                                                            newRecipe.data = nil
                                                        }
                                                        modelContext.insert(newRecipe)
                                                        
                                                        do {
                                                            try modelContext.save()  // <-- Ensure the changes are saved
                                                            print("Saved")
                                                            dismiss()
                                                        } catch {
                                                            print("Failed to save recipe: \(error)")
                                                        }
                                                        
                                                     }
                                                }
                                                
                                            }
                                        }
                                    } catch {
                                        print("Error decoding JSON: \(error)")
                                    }
                                }
                            }
                        }
                        .disabled(isGeneratingRecipe)
                    }
                }
            }
            .onAppear {
                imagePicker.setup(vm)
            }
            .onChange(of: vm.cameraImage) {
                if let image = vm.cameraImage {
                    vm.data = image.jpegData(compressionQuality: 0.8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                if vm.isUpDating {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(
                            action: {
                                if vm.isUpDating {
                                    if let recipe = vm.recipe {
                                        if vm.image != Constants.placeholder {
                                            recipe.data = vm.image.jpegData(compressionQuality: 0.8)
                                        } else {
                                            recipe.data = nil
                                        }
                                        recipe.title = vm.title
                                        dismiss()
                                    }
                                }
                            }
                        ) {Text("Update")
                        }.disabled(vm.isDisabled)
                    }
                }
            }
        }
    }   
}

struct RecipeAPIResponse: Codable {
    var title: String
    var ingredients: [String]
    var instructions: [String]
    var recipeDescription: String
}

#Preview {
    UpdateEditFormView(vm: UpdateEditFormViewModel())
}

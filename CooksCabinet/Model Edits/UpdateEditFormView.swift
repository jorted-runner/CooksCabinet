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
    var body: some View {
        NavigationStack {
            Form {
                if vm.isUpDating {
                    // Update Recipe Form
                    Text("Is updating...")
                } else {
                    // New Recipe Form
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
                            } else {
                                let newRecipe = RecipeModel(
                                    title: vm.title,
                                    ingredients: [IngredientModel(
                                        name: "",
                                        quantity: "0"
                                    )],
                                    instructions: ["test step"],
                                    recipeDescription: "test desc"
                                )
                                if vm.image != Constants.placeholder {
                                    newRecipe.data = vm.image.jpegData(compressionQuality: 0.8)
                                } else {
                                    newRecipe.data = nil
                                }
                                modelContext.insert(newRecipe)
                                dismiss()
                            }
                        }
                    ) {Text(vm.isUpDating ? "Update" : "Add")
                    }.disabled(vm.isDisabled)
                }
            }
        }
    }
}

#Preview {
    UpdateEditFormView(vm: UpdateEditFormViewModel())
}

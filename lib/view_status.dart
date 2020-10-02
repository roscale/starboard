enum Status {
  SUCCESS,
  LOADING,
  ERROR,
}

mixin ViewStatus {
  Status status = Status.SUCCESS;
  Object error;

  bool isSuccess() => status == Status.SUCCESS;

  bool isLoading() => status == Status.LOADING;

  bool hasError() => status == Status.ERROR;

  void notifySuccess() {
    status = Status.SUCCESS;
    error = null;
    notifyListeners();
  }

  void notifyLoading() {
    status = Status.LOADING;
    error = null;
    notifyListeners();
  }

  void notifyError(Object e) {
    status = Status.ERROR;
    error = e;
    notifyListeners();
  }

  void notifyListeners();
}

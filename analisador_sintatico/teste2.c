int main() {
    int a, b, c;
    a = 10;
    b = 20;
    c = a + b * 2;

    if (c > 30) {
        c = c - 10;
    } else {
        c = c + 10;
    }

    while (a < b) {
        a = a + 1;
    }

    return c;
}
